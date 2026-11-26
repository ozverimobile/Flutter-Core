import Foundation

/// Gelen arama push'u (VoIP) için PushKit token'ı.
///
/// SDK PushKit'e kaydolmaz: Apple her VoIP push'ta aynı çağrı içinde CallKit'e arama
/// raporlanmasını ister; bu iş uygulamanındır. Uygulama `PKPushRegistry` ile token'ı alır ve
/// buraya verir; SDK token'ı cihaz kaydına bağlar:
///
/// - `PUT /api/apps/{appId}/devices/{deviceId}/voip-token`, cihaz kaydı varsa hemen, yoksa
///   kayıttan sonra; her yeni `POST /devices`'tan sonra yeniden.
/// - Token geçersizleşince `DELETE …/voip-token`.
/// - VoIP token'ı verilmiş uygulamada bildirim izni olmasa da cihaz kaydolur (arama push'u izin
///   istemez); bildirim aboneliği (`subscribed`) kapalı gider, izin verilince açılır.
///
/// ```swift
/// import flutter_core
///
/// func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
///   CoreCloudNotificationVoip.setToken(credentials.token)
/// }
///
/// func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
///   CoreCloudNotificationVoip.invalidateToken()
/// }
/// ```
///
/// Dart `initialize`'dan önce çağrılabilir (PushKit açılışta erken gelir); gönderim
/// `initialize`'dan sonra yapılır.
public enum CoreCloudNotificationVoip {
  public static func setToken(_ token: Data) {
    CoreCloudNotificationManager.shared.setVoipToken(token)
  }

  public static func invalidateToken() {
    CoreCloudNotificationManager.shared.clearVoipToken()
  }
}
