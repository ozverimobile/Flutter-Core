import Foundation
import UserNotifications

// Uygulama (flutter_core pod'u) ile Notification Service Extension (flutter_core_notification_extension
// pod'u) arasında paylaşılan kod. UIApplication gibi extension'da olmayan API'ler kullanılmaz.

// MARK: - Log

/// OneSignal ile aynı seviye sırası: none=0, fatal=1, error=2, warn=3, info=4, debug=5, verbose=6.
public enum CoreCloudNotificationLog {
  public static var level: Int {
    get { CoreCloudNotificationStore.shared.defaults.object(forKey: CoreCloudNotificationStore.Key.logLevel) as? Int ?? 3 }
    set { CoreCloudNotificationStore.shared.defaults.set(newValue, forKey: CoreCloudNotificationStore.Key.logLevel) }
  }

  public static func e(_ message: @autoclosure () -> String) { write(2, "E", message()) }
  public static func w(_ message: @autoclosure () -> String) { write(3, "W", message()) }
  public static func i(_ message: @autoclosure () -> String) { write(4, "I", message()) }
  public static func d(_ message: @autoclosure () -> String) { write(5, "D", message()) }

  private static func write(_ required: Int, _ tag: String, _ message: String) {
    guard level >= required else { return }
    NSLog("[CoreCloudNotification][%@] %@", tag, message)
  }
}

// MARK: - Depo

/// Uygulama ile extension'ın ortak UserDefaults'u (App Group).
///
/// Grup adı Info.plist'teki `CoreCloudNotificationAppGroup` anahtarından okunur; yoksa OneSignal'ın kullandığı
/// `group.<uygulama bundle id>.onesignal` adı kullanılır. Böylece OneSignal'dan geçen uygulamaların
/// mevcut App Group'u ve extension target'ı değişmeden çalışır.
public final class CoreCloudNotificationStore {
  public static let shared = CoreCloudNotificationStore()

  public enum Key {
    public static let appId = "corecloudnotification.appId"
    public static let baseUrl = "corecloudnotification.baseUrl"
    public static let openLaunchUrls = "corecloudnotification.openLaunchUrls"
    public static let logLevel = "corecloudnotification.logLevel"
    public static let token = "corecloudnotification.token"
    public static let deviceId = "corecloudnotification.deviceId"
    public static let registeredToken = "corecloudnotification.registeredToken"
    public static let registeredEndpoint = "corecloudnotification.registeredEndpoint"
    public static let needsRegister = "corecloudnotification.needsRegister"
    public static let synced = "corecloudnotification.synced"
    public static let externalUserId = "corecloudnotification.externalUserId"
    public static let tags = "corecloudnotification.tags"
    public static let aliases = "corecloudnotification.aliases"
    public static let email = "corecloudnotification.email"
    /// Cihazdaki badge sayısı; `_badgeIncrement` için extension buna ekler.
    public static let badgeCount = "corecloudnotification.badgeCount"
    public static let language = "corecloudnotification.language"
    public static let subscribed = "corecloudnotification.subscribed"
    public static let pendingEvents = "corecloudnotification.pendingEvents"
  }

  public let appGroup: String
  public let defaults: UserDefaults
  public let isSharedWithExtension: Bool

  private init() {
    let configured = Bundle.main.object(forInfoDictionaryKey: "CoreCloudNotificationAppGroup") as? String
    appGroup = configured ?? "group.\(CoreCloudNotificationStore.mainBundleIdentifier).onesignal"
    if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) != nil,
       let shared = UserDefaults(suiteName: appGroup) {
      defaults = shared
      isSharedWithExtension = true
    } else {
      defaults = .standard
      isSharedWithExtension = false
    }
  }

  /// Extension içindeyken de ana uygulamanın bundle id'si (son bileşen atılır).
  public static var mainBundleIdentifier: String {
    let bundle = Bundle.main
    let id = bundle.bundleIdentifier ?? ""
    guard bundle.bundleURL.pathExtension == "appex" else { return id }
    return id.split(separator: ".").dropLast().joined(separator: ".")
  }

  public var deviceId: String? {
    get { defaults.string(forKey: Key.deviceId) }
    set { defaults.set(newValue, forKey: Key.deviceId) }
  }

  public var endpoint: URL? {
    CoreCloudNotificationStore.endpoint(baseUrl: defaults.string(forKey: Key.baseUrl), appId: defaults.string(forKey: Key.appId))
  }

  public static func endpoint(baseUrl: String?, appId: String?) -> URL? {
    guard var base = baseUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !base.isEmpty,
          let appId = appId?.trimmingCharacters(in: .whitespacesAndNewlines), !appId.isEmpty
    else { return nil }
    while base.hasSuffix("/") { base.removeLast() }
    guard let url = URL(string: "\(base)/api/v1/apps/\(appId)"),
          url.scheme == "http" || url.scheme == "https"
    else { return nil }
    return url
  }
}

// MARK: - API

public enum CoreCloudNotificationAPIResult {
  case ok(Int, Data)
  /// `status` nil ise istek sunucuya ulaşamadı.
  case fail(Int?, String)

  /// Sonra tekrar denenmeli mi: ağ hatası, 429 ve 5xx.
  public var isRetryable: Bool {
    guard case let .fail(status, _) = self else { return false }
    guard let status else { return true }
    return status == 429 || status >= 500
  }

  public var status: Int? {
    switch self {
    case let .ok(status, _): return status
    case let .fail(status, _): return status
    }
  }
}

/// Push backend'inin mobil uç noktaları; kimlik doğrulama istemez.
public struct CoreCloudNotificationAPI {
  public let endpoint: URL

  /// Son `429` yanıtındaki `Retry-After` (saniye).
  public static var retryAfterSeconds: Int?

  public init(endpoint: URL) {
    self.endpoint = endpoint
  }

  public init?(store: CoreCloudNotificationStore = .shared) {
    guard let endpoint = store.endpoint else { return nil }
    self.endpoint = endpoint
  }

  public func send(_ method: String, _ path: String, _ body: [String: Any]?,
                   completion: @escaping (CoreCloudNotificationAPIResult) -> Void) {
    var request = URLRequest(url: endpoint.appendingPathComponent(path))
    request.httpMethod = method
    request.timeoutInterval = 20
    if let body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    }
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error {
        completion(.fail(nil, "\(method) \(path): \(error.localizedDescription)"))
        return
      }
      let status = (response as? HTTPURLResponse)?.statusCode ?? 0
      let data = data ?? Data()
      if (200 ..< 300).contains(status) {
        completion(.ok(status, data))
      } else {
        if status == 429 {
          // value(forHTTPHeaderField:) iOS 13+; extension iOS 12'yi de destekliyor.
          let headers = (response as? HTTPURLResponse)?.allHeaderFields ?? [:]
          let header = headers.first { ($0.key as? String)?.lowercased() == "retry-after" }?.value as? String
          CoreCloudNotificationAPI.retryAfterSeconds = header.flatMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        }
        completion(.fail(status, "HTTP \(status) \(method) \(path) \(String(data: data, encoding: .utf8) ?? "")"))
      }
    }.resume()
  }

  /// Bloklayıcı sürüm; ana thread'den çağrılmamalı.
  public func sendSync(_ method: String, _ path: String, _ body: [String: Any]?) -> CoreCloudNotificationAPIResult {
    let semaphore = DispatchSemaphore(value: 0)
    var result = CoreCloudNotificationAPIResult.fail(nil, "zaman aşımı")
    send(method, path, body) {
      result = $0
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 25)
    return result
  }
}

// MARK: - Event'ler

/// `received` / `opened` event'leri. Kalıcı kuyruğa yazılır; cihaz kaydı yoksa ya da ağ yoksa
/// uygulama sonraki açılışta gönderir. Aynı event'in iki kez gitmesi backend'de sorun değildir.
public enum CoreCloudNotificationEvents {
  private static let lock = NSLock()
  private static let maxPending = 100

  /// Son gönderimi yarıda kesen hata kodu (ör. `429`); uygulama tekrar denemeyi buna göre planlar.
  public private(set) static var lastFlushStatus: Int?

  /// Bloklayıcıdır; ana thread'den çağrılmamalı.
  public static func trackSync(notificationId: String, type: String, actionId: String? = nil) {
    lock.lock()
    var pending = pendingEvents()
    var event = ["nid": notificationId, "type": type]
    event["actionId"] = actionId
    pending.append(event)
    if pending.count > maxPending { pending.removeFirst(pending.count - maxPending) }
    CoreCloudNotificationStore.shared.defaults.set(pending, forKey: CoreCloudNotificationStore.Key.pendingEvents)
    lock.unlock()
    flushSync()
  }

  /// Bloklayıcıdır; ana thread'den çağrılmamalı.
  public static func flushSync() {
    lock.lock()
    defer { lock.unlock() }
    let store = CoreCloudNotificationStore.shared
    guard let api = CoreCloudNotificationAPI(store: store), let deviceId = store.deviceId else { return }
    var remaining: [[String: String]] = []
    var stop = false
    lastFlushStatus = nil
    for event in pendingEvents() {
      guard !stop, let nid = event["nid"], let type = event["type"] else {
        remaining.append(event)
        continue
      }
      var body = ["deviceId": deviceId, "type": type]
      body["actionId"] = event["actionId"]
      let result = api.sendSync("POST", "notifications/\(nid)/events", body)
      switch result {
      case .ok:
        CoreCloudNotificationLog.d("Event gönderildi: \(type) \(nid)")
      case let .fail(status, message) where result.isRetryable:
        CoreCloudNotificationLog.w("Event gönderilemedi, sonra denenecek: \(message)")
        lastFlushStatus = status
        remaining.append(event)
        stop = true
      case let .fail(_, message):
        CoreCloudNotificationLog.w("Event reddedildi: \(message)")
      }
    }
    store.defaults.set(remaining, forKey: CoreCloudNotificationStore.Key.pendingEvents)
  }

  private static func pendingEvents() -> [[String: String]] {
    CoreCloudNotificationStore.shared.defaults.array(forKey: CoreCloudNotificationStore.Key.pendingEvents) as? [[String: String]] ?? []
  }
}

// MARK: - Payload

/// Backend'in gönderdiği bildirimin Dart'a giden hali (OneSignal `OSNotification` alanları).
///
/// Custom data, `_data` anahtarı varsa ondan (nesne veya JSON string), yoksa `aps` ve SDK
/// anahtarları dışındaki üst seviye anahtarlardan okunur.
public struct CoreCloudNotificationPayload {
  /// `_` ile başlayan anahtarlar backend'e ayrılmış; bunlar da öyle.
  static let reservedKeys: Set<String> = ["aps", "url", "imageUrl"]

  public let notificationId: String
  public let userInfo: [AnyHashable: Any]
  public let title: String?
  public let subtitle: String?
  public let body: String?

  public init?(content: UNNotificationContent) {
    guard let nid = content.userInfo["_nid"] as? String else { return nil }
    notificationId = nid
    userInfo = content.userInfo
    title = content.title.isEmpty ? nil : content.title
    subtitle = content.subtitle.isEmpty ? nil : content.subtitle
    body = content.body.isEmpty ? nil : content.body
  }

  public static func isOurs(_ userInfo: [AnyHashable: Any]) -> Bool {
    userInfo["_nid"] is String
  }

  public var launchUrl: String? { userInfo["url"] as? String }
  public var imageUrl: String? { userInfo["imageUrl"] as? String }

  public var additionalData: [String: Any] {
    if let data = userInfo["_data"] as? [String: Any] { return data }
    if let raw = userInfo["_data"] as? String {
      if let data = raw.data(using: .utf8),
         let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        return object
      }
      CoreCloudNotificationLog.w("_data JSON olarak çözülemedi: \(raw)")
    }
    var result: [String: Any] = [:]
    for (key, value) in userInfo {
      guard let key = key as? String, !key.hasPrefix("_"), !CoreCloudNotificationPayload.reservedKeys.contains(key) else { continue }
      result[key] = value
    }
    return result
  }

  public var rawPayload: String? {
    guard JSONSerialization.isValidJSONObject(userInfo),
          let data = try? JSONSerialization.data(withJSONObject: userInfo)
    else { return nil }
    return String(data: data, encoding: .utf8)
  }

  public struct Button {
    public let id: String
    public let text: String
    public let url: String?
  }

  /// Backend `_buttons`'ı JSON string olarak gönderir (en fazla 3).
  public var buttons: [Button] {
    guard let raw = userInfo["_buttons"] as? String, let data = raw.data(using: .utf8),
          let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    else { return [] }
    return array.compactMap { item in
      guard let id = item["id"] as? String else { return nil }
      return Button(id: id, text: item["text"] as? String ?? id, url: item["url"] as? String)
    }
  }

  public func toMap() -> [String: Any] {
    var map: [String: Any] = [
      "notificationId": notificationId,
      "additionalData": additionalData,
      "buttons": buttons.map { button -> [String: Any] in
        var map: [String: Any] = ["id": button.id, "text": button.text]
        map["url"] = button.url
        return map
      },
    ]
    map["title"] = title
    map["subtitle"] = subtitle
    map["body"] = body
    map["launchUrl"] = launchUrl
    map["bigPicture"] = imageUrl
    map["rawPayload"] = rawPayload
    if let aps = userInfo["aps"] as? [String: Any] {
      map["badge"] = aps["badge"]
      map["sound"] = aps["sound"] as? String
      map["category"] = aps["category"] as? String
      map["threadId"] = aps["thread-id"] as? String
      map["contentAvailable"] = (aps["content-available"] as? Int) == 1
      map["mutableContent"] = (aps["mutable-content"] as? Int) == 1
    }
    return map
  }
}

// MARK: - Aksiyon butonları

/// Backend butonlu bildirimde `aps.category` olarak buton setinden üretilmiş sabit bir id gönderir.
/// Bildirim gösterilmeden önce bu id ile `_buttons`'tan bir `UNNotificationCategory` kaydedilir;
/// aynı buton seti hep aynı id'yi ürettiği için kategori bir kez eklenir.
public enum CoreCloudNotificationCategories {
  /// Bloklayıcıdır; ana thread'den çağrılmamalı.
  public static func registerSync(for content: UNNotificationContent) {
    guard let payload = CoreCloudNotificationPayload(content: content) else { return }
    let buttons = payload.buttons
    let identifier = content.categoryIdentifier
    guard !buttons.isEmpty, !identifier.isEmpty else { return }

    let center = UNUserNotificationCenter.current()
    let semaphore = DispatchSemaphore(value: 0)
    center.getNotificationCategories { categories in
      defer { semaphore.signal() }
      guard !categories.contains(where: { $0.identifier == identifier }) else { return }
      let actions = buttons.map { UNNotificationAction(identifier: $0.id, title: $0.text, options: [.foreground]) }
      let category = UNNotificationCategory(identifier: identifier, actions: actions, intentIdentifiers: [], options: [])
      center.setNotificationCategories(categories.union([category]))
      CoreCloudNotificationLog.d("Bildirim kategorisi kaydedildi: \(identifier)")
    }
    _ = semaphore.wait(timeout: .now() + 3)
  }
}

// MARK: - Badge

public enum CoreCloudNotificationBadge {
  /// Extension'da: `_badgeIncrement` varsa saklanan sayıya ekler, `aps.badge` varsa onu saklar.
  public static func apply(to content: UNMutableNotificationContent) {
    let defaults = CoreCloudNotificationStore.shared.defaults
    if let raw = content.userInfo["_badgeIncrement"] as? String, let increment = Int(raw) {
      let count = max(0, defaults.integer(forKey: CoreCloudNotificationStore.Key.badgeCount) + increment)
      defaults.set(count, forKey: CoreCloudNotificationStore.Key.badgeCount)
      content.badge = NSNumber(value: count)
    } else if let badge = content.badge {
      defaults.set(badge.intValue, forKey: CoreCloudNotificationStore.Key.badgeCount)
    }
  }

  public static func reset(to count: Int = 0) {
    CoreCloudNotificationStore.shared.defaults.set(count, forKey: CoreCloudNotificationStore.Key.badgeCount)
  }
}
