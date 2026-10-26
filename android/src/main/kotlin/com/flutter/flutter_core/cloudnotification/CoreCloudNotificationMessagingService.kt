package com.flutter.flutter_core.cloudnotification

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * FCM giriş noktası. Uygulama kapalıyken de çalışır; Flutter engine'i gerekmez.
 *
 * Görünür (`notification` bloklu) mesajlarda sadece uygulama ön plandayken çağrılır; arka planda
 * bildirimi sistem gösterir. Data-only mesajlarda her durumda çağrılır.
 */
class CoreCloudNotificationMessagingService : FirebaseMessagingService() {
    override fun onNewToken(token: String) {
        CoreCloudNotification.ensureInit(applicationContext)
        CoreCloudNotification.onNewToken(token)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        CoreCloudNotification.ensureInit(applicationContext)
        CoreCloudNotification.onMessage(message)
    }
}
