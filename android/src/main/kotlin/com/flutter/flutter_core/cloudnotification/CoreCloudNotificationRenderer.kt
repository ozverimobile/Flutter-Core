package com.flutter.flutter_core.cloudnotification

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.net.URL

/** SDK'nın kendi gösterdiği bildirimler (ön planda gelenler ve data-only mesajlar). */
internal object CoreCloudNotificationRenderer {
    /** Backend `android.channelId` göndermezse kullanılan kanal; manifest'teki varsayılanla aynı. */
    const val DEFAULT_CHANNEL_ID = "genel"
    private const val DEFAULT_CHANNEL_NAME = "Genel"

    /** Uygulama kendi ikonunu aynı isimle `res/drawable` altına koyarak ezebilir. */
    private const val DEFAULT_SMALL_ICON = "ic_stat_core_notification"

    fun ensureDefaultChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(DEFAULT_CHANNEL_ID) == null) {
            manager.createNotificationChannel(
                NotificationChannel(DEFAULT_CHANNEL_ID, DEFAULT_CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH),
            )
        }
    }

    /** Bloklayıcıdır (görsel indirir); ana thread'den çağrılmamalı. */
    @SuppressLint("MissingPermission")
    fun show(context: Context, payload: CoreCloudNotificationPayload) {
        val compat = NotificationManagerCompat.from(context)
        if (!compat.areNotificationsEnabled()) {
            CoreCloudNotificationLog.w("Bildirim gösterilmedi: bildirim izni yok (${payload.notificationId})")
            return
        }
        val builder = NotificationCompat.Builder(context, resolveChannel(context, payload))
            .setSmallIcon(resolveSmallIcon(context, payload.smallIcon))
            .setContentTitle(payload.title)
            .setContentText(payload.body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(payload.body))
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setContentIntent(contentIntent(context, payload))

        payload.color?.let { runCatching { builder.setColor(Color.parseColor(it)) } }
        // Android 8+ sesi kanaldan alır; daha eski sürümlerde bildirime verilir.
        soundUri(context, payload.sound)?.let { builder.setSound(it) }
        payload.buttons.forEachIndexed { index, button ->
            builder.addAction(0, button.text, contentIntent(context, payload, button.id, index + 1))
        }

        payload.imageUrl?.let(::download)?.let { image ->
            builder.setLargeIcon(image)
                .setStyle(NotificationCompat.BigPictureStyle().bigPicture(image).bigLargeIcon(null as Bitmap?))
        }
        compat.notify(payload.androidNotificationId, builder.build())
    }

    fun cancelAll(context: Context) {
        NotificationManagerCompat.from(context).cancelAll()
    }

    /**
     * Dokunulunca uygulamanın launcher activity'si açılır; data extra olarak verilir. Android 12+
     * trampoline yasağı yüzünden araya receiver/service konmaz, tıklamayı plugin activity'den okur.
     */
    private fun contentIntent(
        context: Context,
        payload: CoreCloudNotificationPayload,
        actionId: String? = null,
        index: Int = 0,
    ): PendingIntent? {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return null
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        payload.data.forEach { (key, value) -> intent.putExtra(key, value) }
        payload.title?.let { intent.putExtra("_title", it) }
        payload.body?.let { intent.putExtra("_body", it) }
        actionId?.let { intent.putExtra(CoreCloudNotificationPayload.EXTRA_ACTION_ID, it) }
        // Her buton ayrı PendingIntent olmalı; request code bildirim id'si + buton sırasından üretilir.
        return PendingIntent.getActivity(
            context,
            payload.androidNotificationId * 31 + index,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    /** `_sound`: `res/raw` altındaki dosya adı (uzantısız); `default` veya bulunamazsa varsayılan ses. */
    private fun soundUri(context: Context, sound: String?): Uri? {
        if (sound.isNullOrBlank() || sound == "default") return null
        val name = sound.substringBeforeLast('.')
        @Suppress("DiscouragedApi")
        val id = context.resources.getIdentifier(name, "raw", context.packageName)
        if (id == 0) {
            CoreCloudNotificationLog.w("Bildirim sesi bulunamadı: res/raw/$name")
            return null
        }
        return Uri.parse("android.resource://${context.packageName}/$id")
    }

    /**
     * Kanal yoksa: backend `_channelName` gönderdiyse oluşturulur (OneSignal'ın kanal yönetimi gibi),
     * göndermediyse varsayılan kanala düşülür.
     */
    private fun resolveChannel(context: Context, payload: CoreCloudNotificationPayload): String {
        val id = payload.channelId ?: return DEFAULT_CHANNEL_ID
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return id
        val manager = context.getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(id) != null) return id
        val name = payload.channelName
        if (name != null) {
            val channel = NotificationChannel(id, name, NotificationManager.IMPORTANCE_HIGH)
            soundUri(context, payload.sound)?.let {
                channel.setSound(it, AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_NOTIFICATION).build())
            }
            manager.createNotificationChannel(channel)
            return id
        }
        CoreCloudNotificationLog.w("'$id' kanalı yok, '$DEFAULT_CHANNEL_ID' kullanıldı")
        return DEFAULT_CHANNEL_ID
    }

    @SuppressLint("DiscouragedApi")
    private fun resolveSmallIcon(context: Context, name: String?): Int {
        val resources = context.resources
        val pkg = context.packageName
        for (candidate in listOfNotNull(name, DEFAULT_SMALL_ICON)) {
            val id = resources.getIdentifier(candidate, "drawable", pkg)
                .takeIf { it != 0 } ?: resources.getIdentifier(candidate, "mipmap", pkg)
            if (id != 0) return id
        }
        return context.applicationInfo.icon
    }

    private fun download(url: String): Bitmap? = runCatching {
        URL(url).openStream().use { BitmapFactory.decodeStream(it) }
    }.onFailure { CoreCloudNotificationLog.w("Görsel indirilemedi: $url ($it)") }.getOrNull()
}
