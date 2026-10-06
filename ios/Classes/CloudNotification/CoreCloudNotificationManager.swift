import Foundation
import UIKit
import UserNotifications

/// Push SDK'sının iOS çekirdeği (uygulama tarafı). Android'deki `CoreCloudNotification` ile aynı mantık:
/// kullanıcı/tag/dil "istenen durum" olarak saklanır, backend'e gönderilmiş son durumla farkı tek
/// PATCH ile gider. Cihaz kaydından önce yapılan çağrılar kaybolmaz, ağ hatasında sonraki
/// açılışta tekrar denenir. Tüm ağ işleri seri kuyrukta sırayla yapılır.
final class CoreCloudNotificationManager {
  static let shared = CoreCloudNotificationManager()

  /// Abonelik durumu değişince (kayıt, token, izin, optIn/optOut) çağrılır; ana thread.
  var onSubscriptionChanged: (([String: Any]) -> Void)?

  private let store = CoreCloudNotificationStore.shared
  private var defaults: UserDefaults { store.defaults }
  private typealias Key = CoreCloudNotificationStore.Key
  private let queue = DispatchQueue(label: "flutter_core.cloud_notification")

  /// Bu süreçte Dart `initialize` çağırdı mı; çağırmadıysa ön plan geçişlerinde session atılmaz.
  private(set) var started = false

  // MARK: - Yapılandırma

  func initialize(appId: String, baseUrl: String, openLaunchUrls: Bool) {
    defaults.set(appId, forKey: Key.appId)
    defaults.set(baseUrl, forKey: Key.baseUrl)
    defaults.set(openLaunchUrls, forKey: Key.openLaunchUrls)
    started = true
    CoreCloudNotificationLog.i("initialize appId=\(appId) baseUrl=\(baseUrl) environment=\(CoreCloudNotificationManager.apnsEnvironment) appGroup=\(store.appGroup) shared=\(store.isSharedWithExtension)")
    // Token izinden bağımsız alınır; backend'e kayıt ise izin verilince yapılır.
    DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
    queue.async {
      self.syncLocked()
      self.sessionLocked()
      CoreCloudNotificationEvents.flushSync()
    }
  }

  var openLaunchUrls: Bool { defaults.object(forKey: Key.openLaunchUrls) as? Bool ?? true }

  func setToken(_ deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    guard defaults.string(forKey: Key.token) != token else {
      queue.async { self.syncLocked() }
      return
    }
    CoreCloudNotificationLog.i("APNs token: \(token)")
    defaults.set(token, forKey: Key.token)
    notifySubscription()
    queue.async {
      self.syncLocked()
      CoreCloudNotificationEvents.flushSync()
    }
  }

  func onForeground() {
    guard started else { return }
    queue.async {
      self.syncLocked()
      self.sessionLocked()
      CoreCloudNotificationEvents.flushSync()
    }
  }

  /// İzin ayarlardan geri verildiyse rehbere göre `POST /devices` tekrar yapılır.
  func permissionGranted() {
    defaults.set(true, forKey: Key.needsRegister)
    DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
    sync()
    notifySubscription()
  }

  // MARK: - Kullanıcı (OneSignal.login / User.*)

  /// OneSignal'daki gibi: anonimken giriş yapılırsa mevcut tag, alias ve e-posta yeni kullanıcıya
  /// taşınır; başka bir kullanıcıdan geçiliyorsa öncekinin bilgileri silinir.
  func login(_ externalId: String) {
    let current = defaults.string(forKey: Key.externalUserId) ?? ""
    guard current != externalId else { return }
    defaults.set(externalId, forKey: Key.externalUserId)
    if !current.isEmpty { clearUserData() }
    sync()
  }

  /// OneSignal'daki gibi cihaz anonim kullanıcıya döner: kullanıcının e-postası, alias'ları ve
  /// tag'leri silinir, cihaz anonim bildirimleri almaya devam eder. Kayıt silinmez
  /// (`DELETE /devices` kullanılmaz); hiç bildirim istenmiyorsa `optOut`.
  func logout() {
    defaults.set("", forKey: Key.externalUserId)
    clearUserData()
    sync()
  }

  private func clearUserData() {
    defaults.set([String: String](), forKey: Key.tags)
    defaults.set([String: String](), forKey: Key.aliases)
    defaults.set("", forKey: Key.email)
  }

  var externalId: String? {
    let id = defaults.string(forKey: Key.externalUserId) ?? ""
    return id.isEmpty ? nil : id
  }

  var tags: [String: String] { map(Key.tags) }

  func addTags(_ newTags: [String: String]) { editMap(Key.tags) { $0.merge(newTags) { $1 } } }

  func removeTags(_ keys: [String]) { editMap(Key.tags) { map in keys.forEach { map.removeValue(forKey: $0) } } }

  var aliases: [String: String] { map(Key.aliases) }

  func addAliases(_ newAliases: [String: String]) { editMap(Key.aliases) { $0.merge(newAliases) { $1 } } }

  func removeAliases(_ labels: [String]) { editMap(Key.aliases) { map in labels.forEach { map.removeValue(forKey: $0) } } }

  /// Backend e-postayı küçük harfle saklıyor; gereksiz PATCH olmasın diye burada da küçültülür.
  func setEmail(_ email: String) {
    defaults.set(email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), forKey: Key.email)
    sync()
  }

  func removeEmail(_ email: String) {
    guard defaults.string(forKey: Key.email) == email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return }
    setEmail("")
  }

  func setLanguage(_ language: String) {
    defaults.set(language, forKey: Key.language)
    sync()
  }

  func setSubscribed(_ subscribed: Bool) {
    defaults.set(subscribed, forKey: Key.subscribed)
    notifySubscription()
    sync()
  }

  func subscriptionState(completion: @escaping ([String: Any]) -> Void) {
    CoreCloudNotificationManager.isAuthorized { authorized in
      var state: [String: Any] = [
        "optedIn": (self.defaults.object(forKey: Key.subscribed) as? Bool ?? true) && authorized,
      ]
      state["id"] = self.store.deviceId
      state["token"] = self.defaults.string(forKey: Key.token)
      completion(state)
    }
  }

  private func map(_ key: String) -> [String: String] {
    defaults.dictionary(forKey: key) as? [String: String] ?? [:]
  }

  private func editMap(_ key: String, _ change: (inout [String: String]) -> Void) {
    var value = map(key)
    change(&value)
    defaults.set(value, forKey: key)
    sync()
  }

  private func notifySubscription() {
    subscriptionState { state in
      DispatchQueue.main.async { self.onSubscriptionChanged?(state) }
    }
  }

  private func sync() {
    queue.async { self.syncLocked() }
  }

  // MARK: - Event'ler

  func track(_ notificationId: String, _ type: String, actionId: String? = nil) {
    queue.async {
      CoreCloudNotificationEvents.trackSync(notificationId: notificationId, type: type, actionId: actionId)
      self.scheduleRetryIfRateLimited(CoreCloudNotificationEvents.lastFlushStatus)
    }
  }

  // MARK: - Backend senkronizasyonu (sadece kuyrukta)

  private func desiredState() -> [String: Any] {
    [
      "externalUserId": defaults.string(forKey: Key.externalUserId) ?? "",
      "email": defaults.string(forKey: Key.email) ?? "",
      "tags": tags,
      "aliases": aliases,
      "language": defaults.string(forKey: Key.language) ?? CoreCloudNotificationManager.deviceLanguage,
      "timezone": TimeZone.current.identifier,
      "appVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
      "subscribed": defaults.object(forKey: Key.subscribed) as? Bool ?? true,
    ]
  }

  private func syncLocked(retryOn404: Bool = true) {
    guard let api = CoreCloudNotificationAPI(store: store), let token = defaults.string(forKey: Key.token) else { return }
    guard CoreCloudNotificationManager.isAuthorizedSync() else {
      CoreCloudNotificationLog.d("Bildirim izni yok, cihaz kaydı bekletiliyor")
      return
    }
    let desired = desiredState()
    var deviceId = store.deviceId

    let needsRegister = deviceId == nil ||
      defaults.string(forKey: Key.registeredToken) != token ||
      defaults.string(forKey: Key.registeredEndpoint) != api.endpoint.absoluteString ||
      defaults.bool(forKey: Key.needsRegister)
    if needsRegister {
      guard let id = register(api: api, token: token, desired: desired) else { return }
      deviceId = id
    }
    guard let deviceId else { return }

    let synced = defaults.dictionary(forKey: Key.synced) ?? [:]
    let patch = CoreCloudNotificationManager.diff(desired: desired, synced: synced)
    guard !patch.isEmpty else { return }
    let result = api.sendSync("PATCH", "devices/\(deviceId)", patch)
    switch result {
    case .ok:
      defaults.set(desired, forKey: Key.synced)
      CoreCloudNotificationLog.i("Cihaz güncellendi: \(patch)")
    case let .fail(status, message):
      CoreCloudNotificationLog.w("Cihaz güncellenemedi: \(message)")
      scheduleRetryIfRateLimited(status)
      if status == 404, retryOn404 {
        clearDeviceLocked()
        syncLocked(retryOn404: false)
      }
    }
  }

  /// `POST /devices` 200 (kayıt zaten var) ve 201'de gövdedeki tüm alanları kayda yazar ve cihazı
  /// yeniden abone yapar. Boş `externalUserId` / `email` sunucudaki eski değeri temizlesin diye
  /// her zaman gönderilir.
  private func register(api: CoreCloudNotificationAPI, token: String, desired: [String: Any]) -> String? {
    var body: [String: Any] = [
      "platform": "ios",
      "token": token,
      "environment": CoreCloudNotificationManager.apnsEnvironment,
      "deviceModel": CoreCloudNotificationManager.deviceModel,
      "osVersion": UIDevice.current.systemVersion,
      "externalUserId": desired["externalUserId"] ?? "",
      "email": desired["email"] ?? "",
      "language": desired["language"] ?? "",
      "timezone": desired["timezone"] ?? "",
      "appVersion": desired["appVersion"] ?? "",
    ]
    if let tags = desired["tags"] as? [String: String], !tags.isEmpty { body["tags"] = tags }
    if let aliases = desired["aliases"] as? [String: String], !aliases.isEmpty { body["aliases"] = aliases }

    switch api.sendSync("POST", "devices", body) {
    case let .ok(status, data):
      guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let id = json["id"] as? String
      else {
        CoreCloudNotificationLog.e("Cihaz kaydı yanıtında id yok: \(String(data: data, encoding: .utf8) ?? "")")
        return nil
      }
      var synced = desired
      synced["subscribed"] = true
      store.deviceId = id
      defaults.set(token, forKey: Key.registeredToken)
      defaults.set(api.endpoint.absoluteString, forKey: Key.registeredEndpoint)
      defaults.set(false, forKey: Key.needsRegister)
      defaults.set(synced, forKey: Key.synced)
      CoreCloudNotificationLog.i("Cihaz kaydedildi (\(status)): \(id)")
      notifySubscription()
      return id
    case let .fail(status, message):
      CoreCloudNotificationLog.w("Cihaz kaydı başarısız: \(message)")
      scheduleRetryIfRateLimited(status)
      return nil
    }
  }

  static func diff(desired: [String: Any], synced: [String: Any]) -> [String: Any] {
    var patch: [String: Any] = [:]
    for key in ["externalUserId", "email", "language", "timezone", "appVersion"] {
      let value = desired[key] as? String ?? ""
      if synced[key] as? String != value { patch[key] = value }
    }
    let subscribed = desired["subscribed"] as? Bool ?? true
    if synced["subscribed"] as? Bool != subscribed { patch["subscribed"] = subscribed }

    // tags ve aliases: sunucu birleştirir, null değer anahtarı siler.
    for key in ["tags", "aliases"] {
      let wanted = desired[key] as? [String: String] ?? [:]
      let sent = synced[key] as? [String: String] ?? [:]
      var changes: [String: Any] = [:]
      for (k, value) in wanted where sent[k] != value { changes[k] = value }
      for k in sent.keys where wanted[k] == nil { changes[k] = NSNull() }
      if !changes.isEmpty { patch[key] = changes }
    }
    return patch
  }

  private func clearDeviceLocked() {
    CoreCloudNotificationLog.w("deviceId sunucuda bulunamadı, yeniden kaydolunacak")
    store.deviceId = nil
    defaults.removeObject(forKey: Key.synced)
  }

  private var retryScheduled = false

  /// `429`'da sunucunun `Retry-After` süresi kadar bekleyip senkronizasyon ve event'ler tekrar denenir.
  private func scheduleRetryIfRateLimited(_ status: Int?) {
    guard status == 429, !retryScheduled else { return }
    retryScheduled = true
    let seconds = min(max(CoreCloudNotificationAPI.retryAfterSeconds ?? 60, 1), 3600)
    CoreCloudNotificationLog.w("İstek limiti aşıldı, \(seconds) sn sonra tekrar denenecek")
    queue.asyncAfter(deadline: .now() + .seconds(seconds)) {
      self.retryScheduled = false
      self.syncLocked()
      CoreCloudNotificationEvents.flushSync()
      self.scheduleRetryIfRateLimited(CoreCloudNotificationEvents.lastFlushStatus)
    }
  }

  private func sessionLocked() {
    guard let api = CoreCloudNotificationAPI(store: store), let deviceId = store.deviceId else { return }
    let result = api.sendSync("POST", "devices/\(deviceId)/session", nil)
    if case let .fail(status, message) = result {
      CoreCloudNotificationLog.w("Session gönderilemedi: \(message)")
      if status == 404 {
        clearDeviceLocked()
        syncLocked(retryOn404: false)
      }
    }
  }

  // MARK: - Cihaz bilgisi

  static func isAuthorized(_ completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      completion(isGranted(settings.authorizationStatus))
    }
  }

  static func isGranted(_ status: UNAuthorizationStatus) -> Bool {
    switch status {
    case .authorized, .provisional: return true
    default:
      if #available(iOS 14.0, *), status == .ephemeral { return true }
      return false
    }
  }

  /// Bloklayıcıdır; ana thread'den çağrılmamalı.
  static func isAuthorizedSync() -> Bool {
    let semaphore = DispatchSemaphore(value: 0)
    var granted = false
    isAuthorized {
      granted = $0
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 5)
    return granted
  }

  static var deviceLanguage: String {
    let identifier = Locale.preferredLanguages.first ?? Locale.current.identifier
    return identifier.split(whereSeparator: { $0 == "-" || $0 == "_" }).first.map(String.init) ?? "tr"
  }

  static var deviceModel: String {
    if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulated }
    var info = utsname()
    uname(&info)
    return withUnsafePointer(to: &info.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
    }
  }

  /// Uygulamanın gerçekte hangi APNs ortamına kayıtlı olduğu, provisioning profilindeki
  /// `aps-environment`'tan okunur (OneSignal da böyle yapar). Xcode'dan yüklenen build'ler
  /// `development` → `sandbox`; App Store / TestFlight build'lerinde profil gömülü değildir → `production`.
  static let apnsEnvironment: String = {
    #if targetEnvironment(simulator)
    return "sandbox"
    #else
    guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
          let data = try? Data(contentsOf: url),
          let text = String(data: data, encoding: .isoLatin1),
          let start = text.range(of: "<?xml"),
          let end = text.range(of: "</plist>", range: start.lowerBound ..< text.endIndex),
          let plistData = String(text[start.lowerBound ..< end.upperBound]).data(using: .isoLatin1),
          let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
          let entitlements = plist["Entitlements"] as? [String: Any],
          let environment = entitlements["aps-environment"] as? String
    else { return "production" }
    return environment == "development" ? "sandbox" : "production"
    #endif
  }()
}
