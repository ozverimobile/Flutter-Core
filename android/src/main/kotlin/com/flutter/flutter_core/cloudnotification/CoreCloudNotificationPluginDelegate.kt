package com.flutter.flutter_core.cloudnotification

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** `flutter_core/cloud_notification` kanalı: Dart `CoreCloudNotification` API'si ile [CoreCloudNotification] arasındaki köprü. */
internal class CoreCloudNotificationPluginDelegate(context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler,
    PluginRegistry.NewIntentListener,
    PluginRegistry.RequestPermissionsResultListener,
    CoreCloudNotification.Bridge {

    private val channel = MethodChannel(messenger, "flutter_core/cloud_notification")
    private var binding: ActivityPluginBinding? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingFallbackToSettings = false

    init {
        CoreCloudNotification.ensureInit(context)
        channel.setMethodCallHandler(this)
        CoreCloudNotification.bridge = this
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        if (CoreCloudNotification.bridge === this) {
            CoreCloudNotification.bridge = null
            CoreCloudNotification.hasWillDisplayListener = false
            CoreCloudNotification.setHasClickListener(false)
        }
    }

    // region Activity

    fun attach(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addOnNewIntentListener(this)
        binding.addRequestPermissionsResultListener(this)
        // Soğuk açılış: uygulama bildirime dokunularak başlatıldı.
        CoreCloudNotification.handleIntent(binding.activity.intent)
    }

    fun detach() {
        binding?.removeOnNewIntentListener(this)
        binding?.removeRequestPermissionsResultListener(this)
        binding = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        CoreCloudNotification.handleIntent(intent)
        // false: intent'i başka plugin'ler de işleyebilsin (deep link vb.).
        return false
    }

    // endregion

    // region Dart → native

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                CoreCloudNotification.initialize(
                    appId = call.argument<String>("appId").orEmpty(),
                    baseUrl = call.argument<String>("baseUrl").orEmpty(),
                    openLaunchUrls = call.argument<Boolean>("openLaunchUrls") ?: true,
                )
                result.success(null)
            }
            "setLogLevel" -> {
                CoreCloudNotification.setLogLevel(call.argument<Int>("level") ?: 3)
                result.success(null)
            }
            "login" -> {
                CoreCloudNotification.login(call.argument<String>("externalId").orEmpty())
                result.success(null)
            }
            "logout" -> {
                CoreCloudNotification.logout()
                result.success(null)
            }
            "getExternalId" -> result.success(CoreCloudNotification.externalId())
            "addTags" -> {
                CoreCloudNotification.addTags(call.argument<Map<String, String>>("tags").orEmpty())
                result.success(null)
            }
            "removeTags" -> {
                CoreCloudNotification.removeTags(call.argument<List<String>>("keys").orEmpty())
                result.success(null)
            }
            "getTags" -> result.success(CoreCloudNotification.tags())
            "addAliases" -> {
                CoreCloudNotification.addAliases(call.argument<Map<String, String>>("aliases").orEmpty())
                result.success(null)
            }
            "removeAliases" -> {
                CoreCloudNotification.removeAliases(call.argument<List<String>>("labels").orEmpty())
                result.success(null)
            }
            "getAliases" -> result.success(CoreCloudNotification.aliases())
            "addEmail" -> {
                CoreCloudNotification.setEmail(call.argument<String>("email").orEmpty())
                result.success(null)
            }
            "removeEmail" -> {
                CoreCloudNotification.removeEmail(call.argument<String>("email").orEmpty())
                result.success(null)
            }
            "setLanguage" -> {
                CoreCloudNotification.setLanguage(call.argument<String>("language").orEmpty())
                result.success(null)
            }
            "optIn" -> {
                CoreCloudNotification.setSubscribed(true)
                result.success(null)
            }
            "optOut" -> {
                CoreCloudNotification.setSubscribed(false)
                result.success(null)
            }
            "getSubscription" -> result.success(CoreCloudNotification.subscriptionState())
            "permission" -> result.success(CoreCloudNotification.notificationsEnabled())
            "canRequestPermission" -> result.success(canRequestPermission())
            "requestPermission" -> requestPermission(call.argument<Boolean>("fallbackToSettings") ?: false, result)
            "setClickListener" -> {
                CoreCloudNotification.setHasClickListener(call.argument<Boolean>("active") ?: false)
                result.success(null)
            }
            "setWillDisplayListener" -> {
                CoreCloudNotification.hasWillDisplayListener = call.argument<Boolean>("active") ?: false
                result.success(null)
            }
            "displayNotification" -> {
                CoreCloudNotification.display(call.argument<String>("notificationId").orEmpty())
                result.success(null)
            }
            "clearAll" -> {
                CoreCloudNotification.clearAll()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // endregion

    // region Native → Dart (CoreCloudNotification.Bridge)

    override fun willDisplay(notification: Map<String, Any?>, decide: (Boolean) -> Unit) {
        channel.invokeMethod("onWillDisplay", notification, object : MethodChannel.Result {
            override fun success(result: Any?) = decide(result != false)
            override fun error(code: String, message: String?, details: Any?) = decide(true)
            override fun notImplemented() = decide(true)
        })
    }

    override fun click(event: Map<String, Any?>) {
        channel.invokeMethod("onClick", event)
    }

    override fun permissionChanged(granted: Boolean) {
        channel.invokeMethod("onPermissionChanged", granted)
    }

    override fun subscriptionChanged(state: Map<String, Any?>) {
        channel.invokeMethod("onSubscriptionChanged", state)
    }

    // endregion

    // region İzin

    private fun canRequestPermission(): Boolean {
        if (CoreCloudNotification.notificationsEnabled()) return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return false
        val activity = binding?.activity ?: return false
        val asked = CoreCloudNotification.prefs.getBoolean(CoreCloudNotification.K_PERMISSION_ASKED, false)
        return !asked || ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.POST_NOTIFICATIONS)
    }

    private fun requestPermission(fallbackToSettings: Boolean, result: MethodChannel.Result) {
        if (CoreCloudNotification.notificationsEnabled()) {
            result.success(true)
            return
        }
        val activity = binding?.activity
        val runtimePermission = Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            activity != null &&
            ContextCompat.checkSelfPermission(activity, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        if (!runtimePermission || !canRequestPermission()) {
            // Android 12 ve altı ya da kalıcı reddedilmiş: sistem penceresi açılamaz.
            if (fallbackToSettings && activity != null) openNotificationSettings(activity)
            result.success(false)
            return
        }
        if (pendingPermissionResult != null) {
            result.error("PERMISSION_IN_PROGRESS", "Bildirim izni zaten isteniyor", null)
            return
        }
        pendingPermissionResult = result
        pendingFallbackToSettings = fallbackToSettings
        CoreCloudNotification.prefs.edit().putBoolean(CoreCloudNotification.K_PERMISSION_ASKED, true).apply()
        ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pendingPermissionResult ?: return true
        pendingPermissionResult = null
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        CoreCloudNotification.checkPermissionChange()
        val activity = binding?.activity
        if (!granted && pendingFallbackToSettings && activity != null &&
            !ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.POST_NOTIFICATIONS)
        ) {
            openNotificationSettings(activity)
        }
        result.success(granted)
        return true
    }

    private fun openNotificationSettings(activity: Activity) {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
        runCatching { activity.startActivity(intent) }
            .onFailure { CoreCloudNotificationLog.w("Bildirim ayarları açılamadı: $it") }
    }

    // endregion

    private companion object {
        const val REQUEST_CODE = 7841
    }
}
