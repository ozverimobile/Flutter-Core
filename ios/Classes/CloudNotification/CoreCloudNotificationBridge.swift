import Flutter
import UIKit
import UserNotifications

/// `flutter_core/cloud_notification` kanalı: Dart `CoreCloudNotification` API'si ile [CoreCloudNotificationManager] arasındaki köprü.
///
/// Bildirim delegate'i: uygulamanın `UNUserNotificationCenter` delegate'i FlutterAppDelegate ise
/// (Flutter şablonu ve `flutter_local_notifications` kurulumu böyle) çağrılar plugin'lere dağıtılır,
/// bu sınıf da `addApplicationDelegate` ile onları alır. Delegate başka bir nesneyse araya bir
/// proxy girer: `_nid` taşıyan bildirimleri burada işler, diğerlerini asıl delegate'e iletir.
/// Delegate, soğuk açılıştaki tıklamayı kaçırmamak için plugin kaydında (uygulama açılırken) kurulur.
final class CoreCloudNotificationBridge: NSObject, FlutterPlugin {
  private static let willDisplayTimeout: TimeInterval = 5
  private static let redisplayKey = "_corepush_redisplay"

  private let channel: FlutterMethodChannel
  private let manager = CoreCloudNotificationManager.shared
  private var proxy: CenterDelegateProxy?

  private var hasClickListener = false
  private var hasWillDisplayListener = false
  private var pendingClicks: [[String: Any]] = []
  private var lastClick: (id: String, time: Date)?
  private var prevented: [String: UNNotificationContent] = [:]
  private var lastPermission: Bool?

  static func register(with registrar: FlutterPluginRegistrar) {
    // FlutterCorePlugin üzerinden kurulur.
  }

  init(registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "flutter_core/cloud_notification", binaryMessenger: registrar.messenger())
    super.init()
    registrar.addMethodCallDelegate(self, channel: channel)
    registrar.addApplicationDelegate(self)
    installNotificationCenterDelegate()

    manager.onSubscriptionChanged = { [weak self] state in
      CoreCloudNotificationLog.d("native → Dart: onSubscriptionChanged \(state)")
      self?.channel.invokeMethod("onSubscriptionChanged", arguments: state)
    }
    NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                           name: UIApplication.willEnterForegroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive),
                                           name: UIApplication.didBecomeActiveNotification, object: nil)
  }

  private func installNotificationCenterDelegate() {
    let center = UNUserNotificationCenter.current()
    let current = center.delegate
    if current == nil, let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate {
      center.delegate = appDelegate
      return
    }
    if current is FlutterAppDelegate || (current != nil && current === proxy) { return }
    let proxy = CenterDelegateProxy(bridge: self, original: current)
    self.proxy = proxy
    center.delegate = proxy
  }

  // MARK: - Dart → native

  /// Geçersiz yapılandırmada Dart'a `PlatformException` olarak dönecek hata; geçerliyse `nil`.
  private static func validateConfig(appId: String, baseUrl: String) -> FlutterError? {
    if appId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return FlutterError(code: "INVALID_APP_ID", message: "appId boş olamaz", details: nil)
    }
    if CoreCloudNotificationStore.endpoint(baseUrl: baseUrl, appId: appId) == nil {
      return FlutterError(code: "INVALID_BASE_URL", message: "baseUrl http(s) ile başlamalı: '\(baseUrl)'", details: nil)
    }
    return nil
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    CoreCloudNotificationLog.v("Dart → native: \(call.method) \(call.arguments ?? "")")
    switch call.method {
    case "initialize":
      let appId = args["appId"] as? String ?? ""
      let baseUrl = args["baseUrl"] as? String ?? ""
      if let error = Self.validateConfig(appId: appId, baseUrl: baseUrl) {
        CoreCloudNotificationLog.e("initialize başarısız: \(error.message ?? "")")
        result(error)
        return
      }
      installNotificationCenterDelegate()
      manager.initialize(appId: appId, baseUrl: baseUrl, openLaunchUrls: args["openLaunchUrls"] as? Bool ?? true)
      clearBadgeIfNeeded()
      CoreCloudNotificationManager.isAuthorized { granted in DispatchQueue.main.async { self.lastPermission = granted } }
      result(nil)
    case "setLogLevel":
      CoreCloudNotificationLog.level = args["level"] as? Int ?? 3
      CoreCloudNotificationLog.d("Log seviyesi: \(CoreCloudNotificationLog.level)")
      result(nil)
    case "login":
      manager.login(args["externalId"] as? String ?? "")
      result(nil)
    case "logout":
      manager.logout()
      result(nil)
    case "getExternalId":
      result(manager.externalId)
    case "addTags":
      manager.addTags(args["tags"] as? [String: String] ?? [:])
      result(nil)
    case "removeTags":
      manager.removeTags(args["keys"] as? [String] ?? [])
      result(nil)
    case "getTags":
      result(manager.tags)
    case "addAliases":
      manager.addAliases(args["aliases"] as? [String: String] ?? [:])
      result(nil)
    case "removeAliases":
      manager.removeAliases(args["labels"] as? [String] ?? [])
      result(nil)
    case "getAliases":
      result(manager.aliases)
    case "addEmail":
      manager.setEmail(args["email"] as? String ?? "")
      result(nil)
    case "removeEmail":
      manager.removeEmail(args["email"] as? String ?? "")
      result(nil)
    case "setLanguage":
      manager.setLanguage(args["language"] as? String ?? "")
      result(nil)
    case "optIn":
      manager.setSubscribed(true)
      result(nil)
    case "optOut":
      manager.setSubscribed(false)
      result(nil)
    case "getSubscription":
      manager.subscriptionState { state in DispatchQueue.main.async { result(state) } }
    case "permission":
      CoreCloudNotificationManager.isAuthorized { granted in DispatchQueue.main.async { result(granted) } }
    case "canRequestPermission":
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        DispatchQueue.main.async { result(settings.authorizationStatus == .notDetermined) }
      }
    case "requestPermission":
      requestPermission(fallbackToSettings: args["fallbackToSettings"] as? Bool ?? false, result: result)
    case "setClickListener":
      hasClickListener = args["active"] as? Bool ?? false
      if hasClickListener { flushPendingClicks() }
      result(nil)
    case "setWillDisplayListener":
      hasWillDisplayListener = args["active"] as? Bool ?? false
      result(nil)
    case "displayNotification":
      display(notificationId: args["notificationId"] as? String ?? "")
      result(nil)
    case "clearAll":
      CoreCloudNotificationLog.d("Tüm bildirimler siliniyor")
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
      setBadge(0)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - UIApplicationDelegate (FlutterAppDelegate üzerinden)

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    manager.setToken(deviceToken)
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    CoreCloudNotificationLog.e("APNs kaydı başarısız: \(error.localizedDescription)")
  }

  /// Sessiz push (`content-available: 1`). Bize ait değilse diğer plugin'lere bırakılır.
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
    guard let nid = userInfo["_nid"] as? String else { return false }
    CoreCloudNotificationLog.d("Remote notification (arka plan) alındı: \(nid)")
    let aps = userInfo["aps"] as? [String: Any]
    if aps?["alert"] == nil {
      manager.track(nid, "received")
    }
    completionHandler(.newData)
    return true
  }

  // MARK: - UNUserNotificationCenterDelegate (FlutterAppDelegate veya proxy üzerinden)

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let content = notification.request.content
    guard let payload = CoreCloudNotificationPayload(content: content) else { return }
    if content.userInfo[CoreCloudNotificationBridge.redisplayKey] != nil {
      CoreCloudNotificationLog.d("Engellenen bildirim tekrar gösteriliyor: \(payload.notificationId)")
      completionHandler(CoreCloudNotificationBridge.presentationOptions)
      return
    }
    CoreCloudNotificationLog.i("Bildirim geldi (ön planda): \(payload.notificationId)")
    CoreCloudNotificationLog.v("Bildirim içeriği: \(payload.toMap())")
    manager.track(payload.notificationId, "received")
    if !payload.buttons.isEmpty {
      DispatchQueue.global(qos: .userInitiated).async {
        CoreCloudNotificationCategories.registerSync(for: content)
        DispatchQueue.main.async {
          self.decideWillPresent(payload: payload, content: content, completionHandler: completionHandler)
        }
      }
      return
    }
    decideWillPresent(payload: payload, content: content, completionHandler: completionHandler)
  }

  private func decideWillPresent(payload: CoreCloudNotificationPayload,
                                 content: UNNotificationContent,
                                 completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    guard hasWillDisplayListener else {
      CoreCloudNotificationLog.d("willDisplay listener yok, bildirim gösteriliyor: \(payload.notificationId)")
      completionHandler(CoreCloudNotificationBridge.presentationOptions)
      return
    }
    var completed = false
    let complete: (Bool) -> Void = { [weak self] display in
      guard !completed else { return }
      completed = true
      CoreCloudNotificationLog.d("foregroundWillDisplay cevabı: göster=\(display)")
      if display {
        completionHandler(CoreCloudNotificationBridge.presentationOptions)
      } else {
        self?.prevented[payload.notificationId] = content
        CoreCloudNotificationLog.i("Bildirim gösterimi engellendi (preventDefault): \(payload.notificationId)")
        completionHandler([])
      }
    }
    CoreCloudNotificationLog.d("native → Dart: onWillDisplay \(payload.notificationId)")
    channel.invokeMethod("onWillDisplay", arguments: payload.toMap()) { result in
      complete((result as? Bool) != false)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + CoreCloudNotificationBridge.willDisplayTimeout) {
      if !completed { CoreCloudNotificationLog.w("foregroundWillDisplay cevabı gelmedi, bildirim gösteriliyor") }
      complete(true)
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    guard let payload = CoreCloudNotificationPayload(content: response.notification.request.content) else { return }
    defer { completionHandler() }
    if response.actionIdentifier == UNNotificationDismissActionIdentifier {
      CoreCloudNotificationLog.d("Bildirim kapatıldı (dismiss): \(payload.notificationId)")
      return
    }
    let actionId = response.actionIdentifier == UNNotificationDefaultActionIdentifier ? nil : response.actionIdentifier
    onClick(payload, actionId: actionId)
  }

  static func handles(_ notification: UNNotification) -> Bool {
    CoreCloudNotificationPayload.isOurs(notification.request.content.userInfo)
  }

  // MARK: - Tıklama

  private func onClick(_ payload: CoreCloudNotificationPayload, actionId: String?) {
    if let last = lastClick, last.id == payload.notificationId, Date().timeIntervalSince(last.time) < 2 {
      CoreCloudNotificationLog.d("Tekrarlanan tıklama yok sayıldı: \(payload.notificationId)")
      return
    }
    lastClick = (payload.notificationId, Date())

    CoreCloudNotificationLog.i("Bildirime dokunuldu: \(payload.notificationId) actionId=\(actionId ?? "-")")
    manager.track(payload.notificationId, "opened", actionId: actionId)
    // Butona basıldıysa butonun url'i, yoksa bildirimin url'i.
    let url = actionId.map { id in payload.buttons.first { $0.id == id }?.url } ?? payload.launchUrl
    if let url { openLaunchUrl(url) }

    var result: [String: Any] = [:]
    result["actionId"] = actionId
    result["url"] = url
    let event: [String: Any] = ["notification": payload.toMap(), "result": result]
    if hasClickListener {
      CoreCloudNotificationLog.d("native → Dart: onClick \(result)")
      channel.invokeMethod("onClick", arguments: event)
    } else {
      // Soğuk açılış: Dart listener'ı henüz eklemedi; ilk eklendiğinde teslim edilir.
      pendingClicks.append(event)
      CoreCloudNotificationLog.d("Click listener yok, tıklama bekletiliyor (bekleyen \(pendingClicks.count))")
    }
  }

  private func flushPendingClicks() {
    let events = pendingClicks
    pendingClicks.removeAll()
    if !events.isEmpty { CoreCloudNotificationLog.d("Bekleyen \(events.count) tıklama Dart'a teslim ediliyor") }
    events.forEach { channel.invokeMethod("onClick", arguments: $0) }
  }

  /// OneSignal gibi: http(s) launch URL'leri tarayıcıda açılır, diğer şemalar uygulamaya bırakılır.
  private func openLaunchUrl(_ string: String) {
    guard manager.openLaunchUrls else {
      CoreCloudNotificationLog.d("launchUrl açılmadı (openLaunchUrls=false): \(string)")
      return
    }
    guard let url = URL(string: string), url.scheme == "http" || url.scheme == "https" else {
      CoreCloudNotificationLog.d("launchUrl http(s) değil, uygulamaya bırakıldı: \(string)")
      return
    }
    CoreCloudNotificationLog.d("launchUrl tarayıcıda açılıyor: \(string)")
    UIApplication.shared.open(url)
  }

  /// `preventDefault()` sonrası Dart'tan `notification.display()`: aynı içerik hemen tekrar gösterilir.
  private func display(notificationId: String) {
    guard let content = prevented.removeValue(forKey: notificationId)?.mutableCopy() as? UNMutableNotificationContent else {
      CoreCloudNotificationLog.w("Gösterilecek bildirim bulunamadı: \(notificationId)")
      return
    }
    CoreCloudNotificationLog.d("Engellenen bildirim gösteriliyor: \(notificationId)")
    var userInfo = content.userInfo
    userInfo[CoreCloudNotificationBridge.redisplayKey] = true
    content.userInfo = userInfo
    let request = UNNotificationRequest(identifier: "\(notificationId)-display", content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request) { error in
      if let error { CoreCloudNotificationLog.w("Bildirim gösterilemedi: \(error.localizedDescription)") }
    }
  }

  private static var presentationOptions: UNNotificationPresentationOptions {
    if #available(iOS 14.0, *) { return [.banner, .list, .sound, .badge] }
    return [.alert, .sound, .badge]
  }

  // MARK: - İzin ve yaşam döngüsü

  private func requestPermission(fallbackToSettings: Bool, result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
      CoreCloudNotificationLog.d("requestPermission: mevcut durum=\(settings.authorizationStatus.rawValue) (0=sorulmadı, 1=reddedildi, 2=izinli, 3=provisional)")
      switch settings.authorizationStatus {
      case .notDetermined:
        CoreCloudNotificationLog.d("requestPermission: sistem izin penceresi açılıyor")
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
          CoreCloudNotificationLog.d("requestPermission sonucu: granted=\(granted)")
          if let error { CoreCloudNotificationLog.w("Bildirim izni hatası: \(error.localizedDescription)") }
          DispatchQueue.main.async {
            self.checkPermissionChange()
            result(granted)
          }
        }
      case .denied:
        CoreCloudNotificationLog.d("requestPermission: daha önce reddedilmiş, ayarlara yönlendirme=\(fallbackToSettings)")
        DispatchQueue.main.async {
          if fallbackToSettings { self.openNotificationSettings() }
          result(false)
        }
      default:
        DispatchQueue.main.async { result(CoreCloudNotificationManager.isGranted(settings.authorizationStatus)) }
      }
    }
  }

  private func openNotificationSettings() {
    var string = UIApplication.openSettingsURLString
    if #available(iOS 16.0, *) { string = UIApplication.openNotificationSettingsURLString }
    if let url = URL(string: string) { UIApplication.shared.open(url) }
  }

  /// İzin sistem ayarlarından değiştiyse Dart'a haber verilir; verildiyse yeniden kaydolunur.
  private func checkPermissionChange() {
    CoreCloudNotificationManager.isAuthorized { granted in
      DispatchQueue.main.async {
        let previous = self.lastPermission
        self.lastPermission = granted
        guard previous != granted else { return }
        CoreCloudNotificationLog.i("Bildirim izni değişti: \(granted)")
        CoreCloudNotificationLog.d("native → Dart: onPermissionChanged \(granted)")
        self.channel.invokeMethod("onPermissionChanged", arguments: granted)
        if granted { self.manager.permissionGranted() }
      }
    }
  }

  @objc private func willEnterForeground() {
    manager.onForeground()
    clearBadgeIfNeeded()
  }

  @objc private func didBecomeActive() {
    guard manager.started else { return }
    checkPermissionChange()
  }

  /// OneSignal varsayılanı: uygulama açılınca badge sıfırlanır. Info.plist'te
  /// `CoreCloudNotificationDisableBadgeClearing = YES` ile kapatılır.
  private func clearBadgeIfNeeded() {
    guard manager.started, Bundle.main.object(forInfoDictionaryKey: "CoreCloudNotificationDisableBadgeClearing") as? Bool != true else { return }
    setBadge(0)
  }

  private func setBadge(_ count: Int) {
    CoreCloudNotificationBadge.reset(to: count)
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(count) { _ in }
    } else {
      UIApplication.shared.applicationIconBadgeNumber = count
    }
  }
}

/// Uygulamanın kendi `UNUserNotificationCenterDelegate`'i FlutterAppDelegate değilse araya girer:
/// bize ait bildirimleri köprüye, diğerlerini asıl delegate'e iletir.
private final class CenterDelegateProxy: NSObject, UNUserNotificationCenterDelegate {
  private weak var bridge: CoreCloudNotificationBridge?
  // Center'ın delegate referansı zayıf; proxy araya girince asıl delegate'i ayakta tutan biz oluyoruz.
  private let original: UNUserNotificationCenterDelegate?

  init(bridge: CoreCloudNotificationBridge, original: UNUserNotificationCenterDelegate?) {
    self.bridge = bridge
    self.original = original
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    if CoreCloudNotificationBridge.handles(notification), let bridge {
      bridge.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    } else if let original,
              original.responds(to: #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:))) {
      original.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
    } else {
      completionHandler([])
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    if CoreCloudNotificationBridge.handles(response.notification), let bridge {
      bridge.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    } else if let original,
              original.responds(to: #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:))) {
      original.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
    } else {
      completionHandler()
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
    if #available(iOS 12.0, *) {
      original?.userNotificationCenter?(center, openSettingsFor: notification)
    }
  }
}
