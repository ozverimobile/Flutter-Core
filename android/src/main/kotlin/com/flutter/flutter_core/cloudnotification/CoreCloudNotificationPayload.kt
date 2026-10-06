package com.flutter.flutter_core.cloudnotification

import android.os.Bundle
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONArray
import org.json.JSONObject

/**
 * Backend'in gönderdiği bildirimin platformdan bağımsız hali.
 *
 * Custom data iki biçimde gelebilir:
 * - Düz anahtarlar (rehberdeki biçim): her değer string'dir.
 * - `_data`: tüm custom data'nın JSON string hali. İç içe nesne ve sayı/bool tipleri ancak bu
 *   şekilde korunur (OneSignal'ın `additionalData` davranışı). Varsa düz anahtarların yerine geçer.
 */
internal class CoreCloudNotificationPayload(
    val notificationId: String,
    val title: String?,
    val body: String?,
    val launchUrl: String?,
    val imageUrl: String?,
    val channelId: String?,
    val channelName: String?,
    val smallIcon: String?,
    /** Ham data (FCM'den gelen string map); tıklama intent'ine aynen konur. */
    val data: Map<String, String>,
    /** Sistem tarafından değil SDK tarafından gösterilecek mi (data-only veya ön planda gelen). */
    val hasNotificationBlock: Boolean,
) {
    class Button(val id: String, val text: String, val url: String?) {
        fun toMap(): Map<String, Any?> = mapOf("id" to id, "text" to text, "url" to url)
    }

    /** Backend `_buttons`'ı JSON string olarak gönderir (en fazla 3). */
    val buttons: List<Button>
        get() {
            val raw = data["_buttons"] ?: return emptyList()
            return runCatching {
                val array = JSONArray(raw)
                (0 until array.length()).map { i ->
                    val o = array.getJSONObject(i)
                    Button(o.getString("id"), o.optString("text", o.getString("id")), o.optString("url").ifEmpty { null })
                }
            }.onFailure { CoreCloudNotificationLog.w("_buttons çözülemedi: $raw") }.getOrDefault(emptyList())
        }

    val sound: String? get() = data["_sound"]
    val color: String? get() = data["_color"]

    /** Android bildirim id'si; aynı `_nid` aynı bildirimi günceller. */
    val androidNotificationId: Int get() = notificationId.hashCode()

    val additionalData: Map<String, Any?>
        get() {
            data["_data"]?.let { raw ->
                runCatching { return toMap(JSONObject(raw)) }
                    .onFailure { CoreCloudNotificationLog.w("_data JSON olarak çözülemedi: $raw") }
            }
            return data.filterKeys { !isReserved(it) }
        }

    fun toMap(): Map<String, Any?> = mapOf(
        "notificationId" to notificationId,
        "title" to title,
        "body" to body,
        "launchUrl" to launchUrl,
        "bigPicture" to imageUrl,
        "additionalData" to additionalData,
        "rawPayload" to JSONObject(data as Map<*, *>).toString(),
        "androidNotificationId" to androidNotificationId,
        "androidChannelId" to channelId,
        "buttons" to buttons.map { it.toMap() },
    )

    companion object {
        /** Butona basılınca intent'e eklenen extra; backend data'sında `_` ile başlayan anahtar olmadığından çakışmaz. */
        const val EXTRA_ACTION_ID = "_actionId"

        // `_` ile başlayan anahtarlar backend'e ayrılmış; `url`, `imageUrl` da öyle.
        private val RESERVED = setOf("url", "imageUrl", "from", "collapse_key")

        fun isReserved(key: String) =
            key.startsWith("_") || key in RESERVED || key.startsWith("google.") || key.startsWith("gcm.")

        fun from(message: RemoteMessage): CoreCloudNotificationPayload? {
            val data = message.data
            val nid = data["_nid"] ?: return null
            val n = message.notification
            return CoreCloudNotificationPayload(
                notificationId = nid,
                title = n?.title ?: data["_title"],
                body = n?.body ?: data["_body"],
                launchUrl = data["url"] ?: n?.link?.toString(),
                imageUrl = n?.imageUrl?.toString() ?: data["imageUrl"],
                channelId = n?.channelId ?: data["_channelId"],
                channelName = data["_channelName"],
                smallIcon = n?.icon ?: data["_smallIcon"],
                data = data,
                hasNotificationBlock = n != null,
            )
        }

        /**
         * Bildirime dokunulunca açılan activity'nin extra'larından. Sistemin gösterdiği bildirimlerde
         * (uygulama arka plandayken `notification` bloğu) extra'lar sadece data'yı içerir; başlık ve
         * metin ancak backend `_title`/`_body` eklerse bilinir.
         */
        @Suppress("DEPRECATION")
        fun from(extras: Bundle): CoreCloudNotificationPayload? {
            val nid = extras.getString("_nid") ?: return null
            val data = HashMap<String, String>()
            for (key in extras.keySet()) {
                val value = extras.get(key)
                if (value is String) data[key] = value
            }
            return CoreCloudNotificationPayload(
                notificationId = nid,
                title = data["_title"],
                body = data["_body"],
                launchUrl = data["url"],
                imageUrl = data["imageUrl"],
                channelId = data["_channelId"],
                channelName = data["_channelName"],
                smallIcon = data["_smallIcon"],
                data = data,
                hasNotificationBlock = false,
            )
        }

        private fun toMap(o: JSONObject): Map<String, Any?> {
            val map = HashMap<String, Any?>()
            for (key in o.keys()) map[key] = unwrap(o.get(key))
            return map
        }

        private fun unwrap(value: Any?): Any? = when (value) {
            is JSONObject -> toMap(value)
            is JSONArray -> (0 until value.length()).map { unwrap(value.get(it)) }
            JSONObject.NULL -> null
            else -> value
        }
    }
}
