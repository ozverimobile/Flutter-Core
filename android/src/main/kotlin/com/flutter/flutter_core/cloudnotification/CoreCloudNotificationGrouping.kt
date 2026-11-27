package com.flutter.flutter_core.cloudnotification

/**
 * Bildirim gruplama kancası (Android). SDK hangi bildirimin hangi gruba girdiğini bilmez; uygulama
 * [resolver] verir, SDK her bildirimde çağırır.
 *
 * [resolver] bildirimin `data` alanlarını alır, grup anahtarı döner (ör. sohbet kimliği); `null`
 * dönerse bildirim gruplanmaz. Anahtar dönen bildirim `setGroup(anahtar)` ile çizilir ve grup başına
 * bir özet bildirim gösterilir (Android 7+ alt bildirimleri özetin altında toplar). Gruptaki son
 * bildirim silinince özet de kalkar.
 *
 * Uygulama açılmadan gelen push'ta da çalışması için `Application.onCreate` içinde verilmelidir:
 * ```kotlin
 * CoreCloudNotificationGrouping.resolver = { data -> if (data["type"] == "1201") data["data"] else null }
 * ```
 * Hata atan resolver gruplamayı kapatır, bildirim yine gösterilir.
 */
object CoreCloudNotificationGrouping {
    @JvmStatic
    @Volatile
    var resolver: ((Map<String, String>) -> String?)? = null

    internal fun groupOf(data: Map<String, String>): String? {
        val resolve = resolver ?: return null
        return runCatching { resolve(data) }
            .onFailure { CoreCloudNotificationLog.w("Bildirim grubu bulunamadı: $it") }
            .getOrNull()
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
    }

    /** Özet bildirimin kimliği: anahtardan, bildirim kimliklerinden ayrı bir alanda. */
    internal fun summaryId(group: String): Int = "core_cloud_notification.group.$group".hashCode()
}
