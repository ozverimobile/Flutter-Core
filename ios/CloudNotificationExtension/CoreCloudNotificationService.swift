import UserNotifications

/// Notification Service Extension'ın yapacağı her şey: uygulama kapalıyken veya arka plandayken
/// `received` event'ini göndermek ve `imageUrl` görselini bildirime eklemek. Sunucu her görünür
/// bildirimde `mutable-content: 1` gönderdiği için her bildirimde çalışır.
///
/// Extension target'ında tek satır yeterli:
/// ```swift
/// import flutter_core_notification_extension
/// class NotificationService: CoreCloudNotificationService {}
/// ```
/// Extension ve uygulama aynı App Group'a sahip olmalı (bkz. `CoreCloudNotificationStore`).
open class CoreCloudNotificationService: UNNotificationServiceExtension {
  private var contentHandler: ((UNNotificationContent) -> Void)?
  private var bestAttemptContent: UNMutableNotificationContent?
  private let lock = NSLock()

  override open func didReceive(_ request: UNNotificationRequest,
                                withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    guard let content = request.content.mutableCopy() as? UNMutableNotificationContent,
          let payload = CoreCloudNotificationPayload(content: request.content)
    else {
      contentHandler(request.content)
      return
    }
    self.contentHandler = contentHandler
    bestAttemptContent = content
    if !CoreCloudNotificationStore.shared.isSharedWithExtension {
      CoreCloudNotificationLog.w("App Group '\(CoreCloudNotificationStore.shared.appGroup)' erişilemiyor; received event'i uygulamaya iletilemez")
    }

    DispatchQueue.global(qos: .userInitiated).async {
      CoreCloudNotificationEvents.trackSync(notificationId: payload.notificationId, type: "received")
      CoreCloudNotificationCategories.registerSync(for: content)
      CoreCloudNotificationBadge.apply(to: content)
      if let imageUrl = payload.imageUrl, let url = URL(string: imageUrl) {
        self.attachImage(from: url, to: content)
      }
      self.finish()
    }
  }

  override open func serviceExtensionTimeWillExpire() {
    CoreCloudNotificationLog.w("Extension süresi doldu, bildirim olduğu gibi gösteriliyor")
    finish()
  }

  /// Alt sınıflar içeriği değiştirmek isterse (ör. kategori, metin) ezebilir; teslimden hemen önce çağrılır.
  open func willDeliver(_ content: UNMutableNotificationContent) {}

  private func attachImage(from url: URL, to content: UNMutableNotificationContent) {
    let semaphore = DispatchSemaphore(value: 0)
    URLSession.shared.downloadTask(with: url) { location, _, error in
      defer { semaphore.signal() }
      guard let location else {
        CoreCloudNotificationLog.w("Görsel indirilemedi: \(url) \(error?.localizedDescription ?? "")")
        return
      }
      let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
      let file = location.deletingLastPathComponent().appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
      do {
        try FileManager.default.moveItem(at: location, to: file)
        content.attachments = [try UNNotificationAttachment(identifier: "image", url: file)]
      } catch {
        CoreCloudNotificationLog.w("Görsel eklenemedi: \(url) \(error.localizedDescription)")
      }
    }.resume()
    _ = semaphore.wait(timeout: .now() + 20)
  }

  private func finish() {
    lock.lock()
    let handler = contentHandler
    contentHandler = nil
    lock.unlock()
    guard let handler, let content = bestAttemptContent else { return }
    willDeliver(content)
    handler(content)
  }
}
