package com.flutter.flutter_core.cloudnotification

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Push SDK'sının Android çekirdeği. Flutter'dan bağımsızdır: uygulama kapalıyken
 * [CoreCloudNotificationMessagingService] üzerinden de çalışır, Dart'a [bridge] varsa haber verir.
 *
 * Kullanıcı/tag/dil gibi bilgiler "istenen durum" olarak saklanır, backend'e gönderilmiş son durum
 * ayrıca tutulur ve aradaki fark tek PATCH ile gönderilir. Böylece cihaz kaydından önce yapılan
 * `login` / `addTags` çağrıları kaybolmaz, ağ hatasında sonraki açılışta tekrar denenir.
 * Tüm ağ işleri tek thread'lik kuyrukta sırayla yapılır (kayıt her zaman PATCH'ten önce biter).
 */
internal object CoreCloudNotification {
    interface Bridge {
        /** Ana thread'de çağrılır; [decide] en fazla bir kez çağrılır (true: göster). */
        fun willDisplay(notification: Map<String, Any?>, decide: (Boolean) -> Unit)

        fun click(event: Map<String, Any?>)

        fun permissionChanged(granted: Boolean)

        fun subscriptionChanged(state: Map<String, Any?>)
    }

    private const val PREFS = "flutter_core_cloud_notification"
    private const val K_APP_ID = "appId"
    private const val K_BASE_URL = "baseUrl"
    private const val K_OPEN_URLS = "openLaunchUrls"
    private const val K_LOG_LEVEL = "logLevel"
    private const val K_TOKEN = "token"
    private const val K_DEVICE_ID = "deviceId"
    private const val K_REG_TOKEN = "registeredToken"
    private const val K_REG_ENDPOINT = "registeredEndpoint"
    private const val K_NEEDS_REGISTER = "needsRegister"
    private const val K_SYNCED = "synced"
    private const val K_EXTERNAL_ID = "externalUserId"
    private const val K_TAGS = "tags"
    private const val K_ALIASES = "aliases"
    private const val K_EMAIL = "email"
    private const val K_LANGUAGE = "language"
    private const val K_SUBSCRIBED = "subscribed"
    private const val K_PENDING_EVENTS = "pendingEvents"
    const val K_PERMISSION_ASKED = "permissionAsked"

    private const val WILL_DISPLAY_TIMEOUT_MS = 5_000L
    private const val MAX_PENDING_EVENTS = 100
    private const val MAX_PREVENTED = 20

    lateinit var app: Context
        private set
    lateinit var prefs: SharedPreferences
        private set

    @Volatile
    private var initialized = false

    /** Bu süreçte Dart `initialize` çağırdı mı; çağırmadıysa ön plan geçişlerinde session atılmaz. */
    @Volatile
    private var started = false

    private val queue = Executors.newSingleThreadExecutor()
    private val renderQueue = Executors.newSingleThreadExecutor()
    private val scheduler = Executors.newSingleThreadScheduledExecutor()
    private val retryScheduled = AtomicBoolean(false)
    private val main = Handler(Looper.getMainLooper())

    @Volatile
    var bridge: Bridge? = null

    @Volatile
    var hasWillDisplayListener = false

    @Volatile
    var isInForeground = false
        private set

    // Aşağıdakiler sadece ana thread'den kullanılır.
    private var hasClickListener = false
    private val pendingClicks = mutableListOf<Map<String, Any?>>()
    private var lastClick: Pair<String, Long>? = null
    private var lastPermission: Boolean? = null
    private var startedActivities = 0
    private var changingConfigurations = false

    private val prevented = LinkedHashMap<String, CoreCloudNotificationPayload>()

    fun ensureInit(context: Context) {
        if (initialized) return
        synchronized(this) {
            if (initialized) return
            app = context.applicationContext
            prefs = app.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            CoreCloudNotificationLog.level = prefs.getInt(K_LOG_LEVEL, 3)
            CoreCloudNotificationRenderer.ensureDefaultChannel(app)
            (app as? Application)?.registerActivityLifecycleCallbacks(lifecycle)
            initialized = true
        }
    }

    // region Yapılandırma

    fun initialize(appId: String, baseUrl: String, openLaunchUrls: Boolean) {
        prefs.edit()
            .putString(K_APP_ID, appId)
            .putString(K_BASE_URL, baseUrl)
            .putBoolean(K_OPEN_URLS, openLaunchUrls)
            .apply()
        started = true
        lastPermission = notificationsEnabled()
        CoreCloudNotificationLog.i("initialize appId=$appId baseUrl=$baseUrl")
        fetchToken()
        queue.execute {
            syncLocked()
            sessionLocked()
            flushEventsLocked()
        }
    }

    fun setLogLevel(level: Int) {
        CoreCloudNotificationLog.level = level
        prefs.edit().putInt(K_LOG_LEVEL, level).apply()
    }

    private fun api(): CoreCloudNotificationApi? =
        CoreCloudNotificationApi.endpoint(prefs.getString(K_BASE_URL, null), prefs.getString(K_APP_ID, null))?.let(::CoreCloudNotificationApi)

    private fun fetchToken() {
        val messaging = messaging() ?: return
        // Manifest'te auto-init kapalı (push kullanmayan uygulamalar için); push açılınca açılır.
        messaging.isAutoInitEnabled = true
        messaging.token
            .addOnSuccessListener { token -> onNewToken(token) }
            .addOnFailureListener { e -> CoreCloudNotificationLog.e("FCM token alınamadı", e) }
    }

    private fun messaging(): FirebaseMessaging? {
        if (FirebaseApp.getApps(app).isEmpty() && FirebaseApp.initializeApp(app) == null) {
            CoreCloudNotificationLog.e("Firebase yapılandırılmamış: android/app/google-services.json eksik")
            return null
        }
        return try {
            FirebaseMessaging.getInstance()
        } catch (e: Exception) {
            CoreCloudNotificationLog.e("FirebaseMessaging başlatılamadı", e)
            null
        }
    }

    fun onNewToken(token: String) {
        if (prefs.getString(K_TOKEN, null) == token) return
        CoreCloudNotificationLog.i("FCM token: $token")
        prefs.edit().putString(K_TOKEN, token).apply()
        notifySubscription()
        queue.execute {
            syncLocked()
            flushEventsLocked()
        }
    }

    // endregion

    // region Kullanıcı (OneSignal.login / User.*)

    /**
     * OneSignal'daki gibi: anonimken giriş yapılırsa mevcut tag, alias ve e-posta yeni kullanıcıya
     * taşınır; başka bir kullanıcıdan geçiliyorsa öncekinin bilgileri silinir.
     */
    fun login(externalId: String) {
        val current = prefs.getString(K_EXTERNAL_ID, "").orEmpty()
        if (current == externalId) return
        val edit = prefs.edit().putString(K_EXTERNAL_ID, externalId)
        if (current.isNotEmpty()) clearUserData(edit)
        edit.apply()
        sync()
    }

    /**
     * OneSignal'daki gibi cihaz anonim kullanıcıya döner: kullanıcının e-postası, alias'ları ve
     * tag'leri silinir, cihaz anonim bildirimleri almaya devam eder. Kayıt silinmez
     * (`DELETE /devices` kullanılmaz); hiç bildirim istenmiyorsa `optOut`.
     */
    fun logout() {
        val edit = prefs.edit().putString(K_EXTERNAL_ID, "")
        clearUserData(edit)
        edit.apply()
        sync()
    }

    private fun clearUserData(edit: SharedPreferences.Editor) {
        edit.putString(K_TAGS, "{}").putString(K_ALIASES, "{}").putString(K_EMAIL, "")
    }

    fun externalId(): String? = prefs.getString(K_EXTERNAL_ID, "").orEmpty().ifEmpty { null }

    fun addTags(tags: Map<String, String>) = editMap(K_TAGS) { json -> tags.forEach { (k, v) -> json.put(k, v) } }

    fun removeTags(keys: List<String>) = editMap(K_TAGS) { json -> keys.forEach { json.remove(it) } }

    fun tags(): Map<String, String> = mapOf(K_TAGS)

    fun addAliases(aliases: Map<String, String>) = editMap(K_ALIASES) { json -> aliases.forEach { (k, v) -> json.put(k, v) } }

    fun removeAliases(labels: List<String>) = editMap(K_ALIASES) { json -> labels.forEach { json.remove(it) } }

    fun aliases(): Map<String, String> = mapOf(K_ALIASES)

    /** Backend e-postayı küçük harfle saklıyor; gereksiz PATCH olmasın diye burada da küçültülür. */
    fun setEmail(email: String) {
        prefs.edit().putString(K_EMAIL, email.trim().lowercase(Locale.ROOT)).apply()
        sync()
    }

    fun removeEmail(email: String) {
        if (prefs.getString(K_EMAIL, "") != email.trim().lowercase(Locale.ROOT)) return
        setEmail("")
    }

    fun setLanguage(language: String) {
        prefs.edit().putString(K_LANGUAGE, language).apply()
        sync()
    }

    fun setSubscribed(subscribed: Boolean) {
        prefs.edit().putBoolean(K_SUBSCRIBED, subscribed).apply()
        notifySubscription()
        sync()
    }

    fun subscriptionState(): Map<String, Any?> = mapOf(
        "id" to prefs.getString(K_DEVICE_ID, null),
        "token" to prefs.getString(K_TOKEN, null),
        "optedIn" to (prefs.getBoolean(K_SUBSCRIBED, true) && notificationsEnabled()),
    )

    private fun json(key: String) = JSONObject(prefs.getString(key, "{}") ?: "{}")

    private fun mapOf(key: String): Map<String, String> {
        val json = json(key)
        return json.keys().asSequence().associateWith { json.getString(it) }
    }

    private fun editMap(key: String, block: (JSONObject) -> Unit) {
        val json = json(key)
        block(json)
        prefs.edit().putString(key, json.toString()).apply()
        sync()
    }

    private fun sync() {
        queue.execute { syncLocked() }
    }

    private fun notifySubscription() {
        val state = subscriptionState()
        main.post { bridge?.subscriptionChanged(state) }
    }

    // endregion

    // region Backend senkronizasyonu (sadece kuyruk thread'inde)

    private fun desiredState(): JSONObject = JSONObject()
        .put("externalUserId", prefs.getString(K_EXTERNAL_ID, "").orEmpty())
        .put("email", prefs.getString(K_EMAIL, "").orEmpty())
        .put("tags", json(K_TAGS))
        .put("aliases", json(K_ALIASES))
        .put("language", prefs.getString(K_LANGUAGE, null) ?: Locale.getDefault().language)
        .put("timezone", TimeZone.getDefault().id)
        .put("appVersion", appVersion())
        .put("subscribed", prefs.getBoolean(K_SUBSCRIBED, true))

    private fun syncLocked(retryOn404: Boolean = true) {
        val api = api() ?: return
        val token = prefs.getString(K_TOKEN, null) ?: return
        if (!notificationsEnabled()) {
            CoreCloudNotificationLog.d("Bildirim izni yok, cihaz kaydı bekletiliyor")
            return
        }
        val desired = desiredState()
        var deviceId = prefs.getString(K_DEVICE_ID, null)

        val needsRegister = deviceId == null ||
            prefs.getString(K_REG_TOKEN, null) != token ||
            prefs.getString(K_REG_ENDPOINT, null) != api.endpoint ||
            prefs.getBoolean(K_NEEDS_REGISTER, false)
        if (needsRegister) {
            deviceId = register(api, token, desired) ?: return
        }

        val synced = JSONObject(prefs.getString(K_SYNCED, "{}") ?: "{}")
        val patch = diff(desired, synced)
        if (patch.length() == 0) return
        when (val result = api.send("PATCH", "devices/$deviceId", patch)) {
            is CoreCloudNotificationApi.Result.Ok -> {
                prefs.edit().putString(K_SYNCED, desired.toString()).apply()
                CoreCloudNotificationLog.i("Cihaz güncellendi: $patch")
            }
            is CoreCloudNotificationApi.Result.Fail -> {
                CoreCloudNotificationLog.w("Cihaz güncellenemedi: ${result.message}")
                scheduleRetryIfRateLimited(result)
                if (result.code == 404 && retryOn404) {
                    clearDeviceLocked()
                    syncLocked(retryOn404 = false)
                }
            }
        }
    }

    /**
     * `POST /devices` 200 (kayıt zaten var) ve 201'de gövdedeki tüm alanları kayda yazar ve cihazı
     * yeniden abone yapar. Boş `externalUserId` / `email` sunucudaki eski değeri temizlesin diye
     * her zaman gönderilir.
     */
    private fun register(api: CoreCloudNotificationApi, token: String, desired: JSONObject): String? {
        val body = JSONObject()
            .put("platform", "android")
            .put("token", token)
            .put("deviceModel", Build.MODEL)
            .put("osVersion", Build.VERSION.RELEASE)
            .put("externalUserId", desired.getString("externalUserId"))
            .put("email", desired.getString("email"))
            .put("language", desired.getString("language"))
            .put("timezone", desired.getString("timezone"))
            .put("appVersion", desired.getString("appVersion"))
        desired.getJSONObject("tags").takeIf { it.length() > 0 }?.let { body.put("tags", it) }
        desired.getJSONObject("aliases").takeIf { it.length() > 0 }?.let { body.put("aliases", it) }

        return when (val result = api.send("POST", "devices", body)) {
            is CoreCloudNotificationApi.Result.Ok -> {
                val id = runCatching { JSONObject(result.body).getString("id") }.getOrNull()
                if (id == null) {
                    CoreCloudNotificationLog.e("Cihaz kaydı yanıtında id yok: ${result.body}")
                    return null
                }
                val synced = JSONObject(desired.toString()).put("subscribed", true)
                prefs.edit()
                    .putString(K_DEVICE_ID, id)
                    .putString(K_REG_TOKEN, token)
                    .putString(K_REG_ENDPOINT, api.endpoint)
                    .putBoolean(K_NEEDS_REGISTER, false)
                    .putString(K_SYNCED, synced.toString())
                    .apply()
                CoreCloudNotificationLog.i("Cihaz kaydedildi (${result.code}): $id")
                notifySubscription()
                id
            }
            is CoreCloudNotificationApi.Result.Fail -> {
                CoreCloudNotificationLog.w("Cihaz kaydı başarısız: ${result.message}")
                scheduleRetryIfRateLimited(result)
                null
            }
        }
    }

    private fun diff(desired: JSONObject, synced: JSONObject): JSONObject {
        val patch = JSONObject()
        for (key in listOf("externalUserId", "email", "language", "timezone", "appVersion", "subscribed")) {
            val value = desired.get(key)
            if (!synced.has(key) || synced.get(key) != value) patch.put(key, value)
        }
        // tags ve aliases: sunucu birleştirir, null değer anahtarı siler.
        for (key in listOf("tags", "aliases")) {
            val wanted = desired.getJSONObject(key)
            val sent = synced.optJSONObject(key) ?: JSONObject()
            val changes = JSONObject()
            for (k in wanted.keys()) {
                if (sent.optString(k, "\u0000") != wanted.getString(k)) changes.put(k, wanted.getString(k))
            }
            for (k in sent.keys()) {
                if (!wanted.has(k)) changes.put(k, JSONObject.NULL)
            }
            if (changes.length() > 0) patch.put(key, changes)
        }
        return patch
    }

    private fun clearDeviceLocked() {
        CoreCloudNotificationLog.w("deviceId sunucuda bulunamadı, yeniden kaydolunacak")
        prefs.edit().remove(K_DEVICE_ID).remove(K_SYNCED).apply()
    }

    private fun sessionLocked() {
        val api = api() ?: return
        val deviceId = prefs.getString(K_DEVICE_ID, null) ?: return
        val result = api.send("POST", "devices/$deviceId/session", null)
        if (result is CoreCloudNotificationApi.Result.Fail) {
            CoreCloudNotificationLog.w("Session gönderilemedi: ${result.message}")
            if (result.code == 404) {
                clearDeviceLocked()
                syncLocked(retryOn404 = false)
            }
        }
    }

    /** `429`'da sunucunun `Retry-After` süresi kadar bekleyip senkronizasyon ve event'ler tekrar denenir. */
    private fun scheduleRetryIfRateLimited(result: CoreCloudNotificationApi.Result.Fail) {
        if (result.code != 429 || retryScheduled.getAndSet(true)) return
        val seconds = (result.retryAfterSeconds ?: 60).coerceIn(1, 3600).toLong()
        CoreCloudNotificationLog.w("İstek limiti aşıldı, $seconds sn sonra tekrar denenecek")
        scheduler.schedule({
            retryScheduled.set(false)
            queue.execute {
                syncLocked()
                flushEventsLocked()
            }
        }, seconds, TimeUnit.SECONDS)
    }

    /** Event'ler kalıcı kuyruğa yazılır; cihaz kaydı yoksa veya ağ yoksa sonra gönderilir. */
    private fun track(nid: String, type: String, actionId: String? = null) {
        queue.execute {
            val pending = pendingEvents()
            val event = JSONObject().put("nid", nid).put("type", type)
            actionId?.let { event.put("actionId", it) }
            pending.put(event)
            while (pending.length() > MAX_PENDING_EVENTS) pending.remove(0)
            prefs.edit().putString(K_PENDING_EVENTS, pending.toString()).apply()
            flushEventsLocked()
        }
    }

    private fun flushEventsLocked() {
        val api = api() ?: return
        val deviceId = prefs.getString(K_DEVICE_ID, null) ?: return
        val pending = pendingEvents()
        val remaining = JSONArray()
        var stop = false
        for (i in 0 until pending.length()) {
            val event = pending.getJSONObject(i)
            if (stop) {
                remaining.put(event)
                continue
            }
            val body = JSONObject().put("deviceId", deviceId).put("type", event.getString("type"))
            event.optString("actionId").takeIf { it.isNotEmpty() }?.let { body.put("actionId", it) }
            when (val result = api.send("POST", "notifications/${event.getString("nid")}/events", body)) {
                is CoreCloudNotificationApi.Result.Ok -> CoreCloudNotificationLog.d("Event gönderildi: $event")
                is CoreCloudNotificationApi.Result.Fail -> if (result.retryable) {
                    CoreCloudNotificationLog.w("Event gönderilemedi, sonra denenecek: ${result.message}")
                    scheduleRetryIfRateLimited(result)
                    remaining.put(event)
                    stop = true
                } else {
                    CoreCloudNotificationLog.w("Event reddedildi: ${result.message}")
                }
            }
        }
        prefs.edit().putString(K_PENDING_EVENTS, remaining.toString()).apply()
    }

    private fun pendingEvents() = JSONArray(prefs.getString(K_PENDING_EVENTS, "[]") ?: "[]")

    // endregion

    // region Bildirimler

    fun onMessage(message: RemoteMessage) {
        val payload = CoreCloudNotificationPayload.from(message)
        if (payload == null) {
            CoreCloudNotificationLog.d("_nid taşımayan FCM mesajı atlandı: ${message.messageId}")
            return
        }
        CoreCloudNotificationLog.i("Bildirim geldi: ${payload.notificationId}")
        track(payload.notificationId, "received")

        val visible = payload.hasNotificationBlock || payload.title != null || payload.body != null
        if (!visible) return // sessiz (data-only, metinsiz) push

        val bridge = bridge
        if (isInForeground && bridge != null && hasWillDisplayListener && !askDartToDisplay(bridge, payload)) {
            synchronized(prevented) {
                prevented[payload.notificationId] = payload
                while (prevented.size > MAX_PREVENTED) prevented.remove(prevented.keys.first())
            }
            CoreCloudNotificationLog.i("Bildirim gösterimi engellendi (preventDefault): ${payload.notificationId}")
            return
        }
        CoreCloudNotificationRenderer.show(app, payload)
    }

    /** FCM thread'inde bekler; Dart cevap vermezse bildirim gösterilir. */
    private fun askDartToDisplay(bridge: Bridge, payload: CoreCloudNotificationPayload): Boolean {
        val latch = CountDownLatch(1)
        val display = AtomicBoolean(true)
        val map = payload.toMap()
        main.post {
            bridge.willDisplay(map) { decision ->
                display.set(decision)
                latch.countDown()
            }
        }
        if (!latch.await(WILL_DISPLAY_TIMEOUT_MS, TimeUnit.MILLISECONDS)) {
            CoreCloudNotificationLog.w("foregroundWillDisplay cevabı gelmedi, bildirim gösteriliyor")
            return true
        }
        return display.get()
    }

    /** `preventDefault()` sonrası Dart'tan `notification.display()`. */
    fun display(notificationId: String) {
        val payload = synchronized(prevented) { prevented.remove(notificationId) } ?: run {
            CoreCloudNotificationLog.w("Gösterilecek bildirim bulunamadı: $notificationId")
            return
        }
        renderQueue.execute { CoreCloudNotificationRenderer.show(app, payload) }
    }

    fun clearAll() {
        CoreCloudNotificationRenderer.cancelAll(app)
    }

    /**
     * Activity intent'i bir bildirim tıklaması mı. Sistem bildirimi de SDK'nın gösterdiği bildirim de
     * launcher activity'yi data'yı extra olarak vererek açar. Ana thread'de çağrılır.
     */
    fun handleIntent(intent: Intent?): Boolean {
        intent ?: return false
        // Son uygulamalar listesinden açılınca eski intent tekrar gelir; tekrar sayılmamalı.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return false
        val extras = intent.extras ?: return false
        val payload = CoreCloudNotificationPayload.from(extras) ?: return false
        val actionId = extras.getString(CoreCloudNotificationPayload.EXTRA_ACTION_ID)
        intent.removeExtra("_nid")
        intent.removeExtra(CoreCloudNotificationPayload.EXTRA_ACTION_ID)
        // Aksiyon butonunda autoCancel çalışmaz; bildirim elle kaldırılır.
        if (actionId != null) NotificationManagerCompat.from(app).cancel(payload.androidNotificationId)
        onClick(payload, actionId)
        return true
    }

    private fun onClick(payload: CoreCloudNotificationPayload, actionId: String?) {
        val now = SystemClock.elapsedRealtime()
        val last = lastClick
        if (last != null && last.first == payload.notificationId && now - last.second < 2_000) return
        lastClick = payload.notificationId to now

        CoreCloudNotificationLog.i("Bildirime dokunuldu: ${payload.notificationId} actionId=$actionId")
        track(payload.notificationId, "opened", actionId)
        // Butona basıldıysa butonun url'i, yoksa bildirimin url'i.
        val url = if (actionId != null) payload.buttons.firstOrNull { it.id == actionId }?.url else payload.launchUrl
        url?.let(::openLaunchUrl)

        val event = mapOf(
            "notification" to payload.toMap(),
            "result" to mapOf("actionId" to actionId, "url" to url),
        )
        val bridge = bridge
        if (hasClickListener && bridge != null) bridge.click(event) else pendingClicks.add(event)
    }

    /** OneSignal gibi: http(s) launch URL'leri tarayıcıda açılır, diğer şemalar uygulamaya bırakılır. */
    private fun openLaunchUrl(url: String) {
        if (!prefs.getBoolean(K_OPEN_URLS, true)) return
        if (!url.startsWith("http://") && !url.startsWith("https://")) return
        runCatching {
            app.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }.onFailure { CoreCloudNotificationLog.w("launchUrl açılamadı: $url ($it)") }
    }

    /** İlk click listener eklenince soğuk açılışta biriken tıklamalar teslim edilir. */
    fun setHasClickListener(active: Boolean) {
        hasClickListener = active
        val bridge = bridge ?: return
        if (!active) return
        val events = pendingClicks.toList()
        pendingClicks.clear()
        events.forEach(bridge::click)
    }

    // endregion

    // region İzin ve yaşam döngüsü

    fun notificationsEnabled(): Boolean = NotificationManagerCompat.from(app).areNotificationsEnabled()

    /** İzin sistem ayarlarından değiştiyse Dart'a haber verilir; geri verildiyse yeniden kaydolunur. */
    fun checkPermissionChange() {
        val now = notificationsEnabled()
        val previous = lastPermission
        lastPermission = now
        if (previous == null || previous == now) return
        CoreCloudNotificationLog.i("Bildirim izni değişti: $now")
        bridge?.permissionChanged(now)
        notifySubscription()
        if (now) {
            prefs.edit().putBoolean(K_NEEDS_REGISTER, true).apply()
            sync()
        }
    }

    private fun onForeground() {
        if (!started) return
        checkPermissionChange()
        queue.execute {
            syncLocked()
            sessionLocked()
            flushEventsLocked()
        }
    }

    private val lifecycle = object : Application.ActivityLifecycleCallbacks {
        override fun onActivityStarted(activity: Activity) {
            startedActivities++
            if (startedActivities == 1) {
                isInForeground = true
                if (changingConfigurations) changingConfigurations = false else onForeground()
            }
        }

        override fun onActivityStopped(activity: Activity) {
            startedActivities = (startedActivities - 1).coerceAtLeast(0)
            changingConfigurations = activity.isChangingConfigurations
            if (startedActivities == 0 && !changingConfigurations) isInForeground = false
        }

        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit
        override fun onActivityResumed(activity: Activity) = Unit
        override fun onActivityPaused(activity: Activity) = Unit
        override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit
        override fun onActivityDestroyed(activity: Activity) = Unit
    }

    // endregion

    @Suppress("DEPRECATION")
    private fun appVersion(): String =
        runCatching { app.packageManager.getPackageInfo(app.packageName, 0).versionName }.getOrNull().orEmpty()
}
