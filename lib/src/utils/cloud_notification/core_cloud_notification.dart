// OneSignal Flutter SDK v5 ile aynı API yüzeyi (`CoreCloudNotification.Notifications`, `CoreCloudNotification.User`...)
// korunduğu için büyük harfli statik alanlar bilinçli.
// ignore_for_file: non_constant_identifier_names, avoid_positional_boolean_parameters

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/src/common/logger/logger_impl.dart';
import 'package:flutter_core/src/utils/cloud_notification/core_cloud_notification_models.dart';

/// Şirket içi push backend'inin istemcisi; OneSignal SDK'sının yerine geçer.
///
/// API OneSignal Flutter SDK v5 ile aynı şekildedir: `OneSignal` yerine `CoreCloudNotification`,
/// `OSNotification...` tipleri yerine `CoreNotification...` (bkz. README'deki eşleme tablosu).
///
/// ```dart
/// await CoreCloudNotification.initialize('APP_ID');
/// CoreCloudNotification.Notifications.addClickListener((event) {
///   final data = event.notification.additionalData;
/// });
/// await CoreCloudNotification.Notifications.requestPermission(true);
/// await CoreCloudNotification.login(user.id);
/// ```
///
/// Davranışlar (OneSignal ile aynı):
/// - Uygulama bildirime dokunularak açıldıysa tıklama, click listener sonradan eklense de teslim edilir.
/// - Ön planda gelen bildirim, listener'lardan biri `preventDefault()` çağırmadıkça gösterilir.
/// - `login`, `addTags` gibi çağrılar cihaz kaydından önce yapılsa da kaybolmaz.
/// - Bildirim izni yokken cihaz backend'e kaydedilmez; izin verilince kaydolur.
///
/// Android ve iOS dışındaki platformlarda (ve testlerde) tüm çağrılar sessizce hiçbir şey yapmaz.
abstract final class CoreCloudNotification {
  /// Test sunucusu. Canlı adres backend'den gelince güncellenecek.
  static const defaultBaseUrl = 'http://10.16.25.98:5080';

  static const _channel = MethodChannel('flutter_core/cloud_notification');
  static bool _handlerInstalled = false;
  static bool _logsEnabled = false;

  static final CoreCloudNotificationNotifications Notifications = CoreCloudNotificationNotifications._();
  static final CoreCloudNotificationUser User = CoreCloudNotificationUser._();
  static final CoreCloudNotificationDebug Debug = CoreCloudNotificationDebug._();

  @visibleForTesting
  static bool? debugIsSupported;

  static bool get isSupported => debugIsSupported ?? (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS));

  /// SDK'yı kurar. Uygulama açılışında bir kez çağrılır; tekrar çağrılması zararsızdır.
  ///
  /// [openLaunchUrls]: bildirimde http(s) `url` varsa dokunulunca tarayıcıda açılsın mı
  /// (OneSignal varsayılanı). Diğer şemalar (deep link) her zaman uygulamaya bırakılır.
  ///
  /// Kurulum başarısız olursa sonuç loglanır ve hata yeniden fırlatılır; native hatalar
  /// [PlatformException] olarak gelir (`code`: `INVALID_APP_ID`, `INVALID_BASE_URL`,
  /// `FIREBASE_NOT_CONFIGURED` (Android), `INITIALIZE_FAILED`).
  ///
  /// [enableLogs]: adım adım ayrıntılı logları açar/kapatır (bkz. [setLogsEnabled]). Verilmezse
  /// mevcut ayar korunur; böylece önceden çağrılmış `Debug.setLogLevel` ezilmez.
  ///
  /// ```dart
  /// try {
  ///   await CoreCloudNotification.initialize(appId, enableLogs: kDebugMode);
  /// } on PlatformException catch (e) {
  ///   // e.code, e.message
  /// }
  /// ```
  static Future<void> initialize(String appId, {String baseUrl = defaultBaseUrl, bool openLaunchUrls = true, bool? enableLogs}) async {
    if (!isSupported) return;
    _ensureHandler();
    try {
      if (enableLogs != null) await setLogsEnabled(enableLogs);
      _log('initialize [1/3] native kurulum: appId=$appId baseUrl=$baseUrl openLaunchUrls=$openLaunchUrls');
      await _invoke<void>('initialize', <String, Object?>{'appId': appId, 'baseUrl': baseUrl, 'openLaunchUrls': openLaunchUrls});
      _log('initialize [2/3] izin ve abonelik durumu okunuyor');
      await Future.wait([Notifications._refreshPermission(), User.pushSubscription._refresh()]);
      final subscription = User.pushSubscription;
      _log(
        'initialize [3/3] durum: izin=${Notifications.permission} deviceId=${subscription.id ?? 'yok (henüz kayıtlı değil)'} '
        'token=${subscription.token != null ? 'var' : 'yok'} optedIn=${subscription.optedIn}',
      );
      CoreLogger.log('CoreCloudNotification.initialize başarılı (appId: $appId, baseUrl: $baseUrl)');
    } on PlatformException catch (e) {
      _logError('initialize başarısız [${e.code}]: ${e.message}');
      rethrow;
    } catch (e) {
      _logError('initialize başarısız: $e');
      rethrow;
    }
  }

  /// Ayrıntılı logları açar/kapatır: Dart tarafında her çağrı, native'den gelen her event ve
  /// listener dağıtımı loglanır; native log seviyesi `verbose` olur (Android logcat
  /// `CoreCloudNotification`, iOS konsol `[CoreCloudNotification]`; HTTP istek/yanıtları dahil).
  ///
  /// Kapatınca native seviye `warn`'a döner. Hatalar her durumda loglanır. Loglar sadece debug ve
  /// profile modda yazılır (`CoreLogger`); native taraftaki bilgiler (token, e-posta) loga düşer.
  static Future<void> setLogsEnabled(bool enabled) => Debug.setLogLevel(enabled ? CoreCloudNotificationLogLevel.verbose : CoreCloudNotificationLogLevel.warn);

  /// Ayrıntılı loglar açık mı.
  static bool get logsEnabled => _logsEnabled;

  static void _log(String message) {
    if (_logsEnabled) CoreLogger.log('[CoreCloudNotification] $message', color: LogColors.cyan);
  }

  static void _logError(String message) => CoreLogger.log('[CoreCloudNotification] $message', color: LogColors.red);

  /// Cihazı kullanıcıyla eşler (`externalUserId`). Backend bu id ile hedefli gönderim yapar.
  ///
  /// OneSignal'daki gibi: anonimken giriş yapılırsa mevcut tag, alias ve e-posta korunur, başka bir
  /// kullanıcıdan geçiliyorsa öncekinin bilgileri silinir.
  static Future<void> login(String externalId) => _invoke<void>('login', <String, Object?>{'externalId': externalId});

  /// Cihazı kullanıcıdan ayırır; kullanıcının e-postası, alias'ları ve tag'leri de silinir.
  /// Cihaz kaydı silinmez, anonim bildirimleri almaya devam eder (OneSignal ile aynı). Hiç bildirim
  /// istenmiyorsa `User.pushSubscription.optOut()`.
  static Future<void> logout() => _invoke<void>('logout');

  static void _ensureHandler() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static Future<Object?> _handleNativeCall(MethodCall call) async {
    final args = call.arguments;
    _log('native → Dart: ${call.method} $args');
    switch (call.method) {
      case 'onWillDisplay':
        return Notifications._dispatchWillDisplay(CoreNotification.fromMap(args as Map<Object?, Object?>));
      case 'onClick':
        Notifications._dispatchClick(CoreNotificationClickEvent.fromMap(args as Map<Object?, Object?>));
      case 'onPermissionChanged':
        Notifications._dispatchPermission(args == true);
      case 'onSubscriptionChanged':
        User.pushSubscription._update(CorePushSubscriptionState.fromMap(args as Map<Object?, Object?>));
    }
    return null;
  }

  static Future<T?> _invoke<T>(String method, [Map<String, Object?>? arguments]) async {
    if (!isSupported) return null;
    _ensureHandler();
    _log('→ $method${arguments == null ? '' : ' $arguments'}');
    final stopwatch = Stopwatch()..start();
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      _log('← $method (${stopwatch.elapsedMilliseconds} ms)${result == null ? '' : ': $result'}');
      return result;
    } on MissingPluginException {
      _logError('$method: native plugin bulunamadı (MissingPluginException), çağrı yok sayıldı');
      return null;
    } on PlatformException catch (e) {
      _logError('$method hata [${e.code}]: ${e.message}');
      rethrow;
    }
  }

  @visibleForTesting
  static void debugReset() {
    _handlerInstalled = false;
    _logsEnabled = false;
    Notifications._reset();
    User.pushSubscription._current = const CorePushSubscriptionState();
    User.pushSubscription._observers.clear();
  }
}

/// `CoreCloudNotification.Notifications` (OneSignal `OneSignal.Notifications`).
final class CoreCloudNotificationNotifications {
  CoreCloudNotificationNotifications._();

  final _clickListeners = <void Function(CoreNotificationClickEvent event)>[];
  final _willDisplayListeners = <void Function(CoreNotificationWillDisplayEvent event)>[];
  final _permissionObservers = <void Function(bool permission)>[];
  bool _permission = false;

  /// Bildirim izni var mı (son bilinen değer; `initialize` ve izin değişince güncellenir).
  bool get permission => _permission;

  /// İzni platformdan tekrar okur.
  Future<bool> permissionNative() async => _permission = await CoreCloudNotification._invoke<bool>('permission') ?? false;

  /// Sistem izin penceresi gösterilebilir mi (henüz sorulmadı veya tekrar sorulabilir).
  Future<bool> canRequest() async => await CoreCloudNotification._invoke<bool>('canRequestPermission') ?? false;

  /// İzin ister. İzin zaten varsa pencere açılmadan `true` döner. [fallbackToSettings] `true` ise
  /// izin daha önce kalıcı olarak reddedildiyse uygulamanın bildirim ayarları açılır.
  Future<bool> requestPermission(bool fallbackToSettings) async {
    CoreCloudNotification._log('requestPermission: mevcut izin=$_permission, ayarlara yönlendirme=$fallbackToSettings');
    final granted = await CoreCloudNotification._invoke<bool>('requestPermission', <String, Object?>{'fallbackToSettings': fallbackToSettings}) ?? false;
    CoreCloudNotification._log('requestPermission sonucu: ${granted ? 'izin verildi' : 'izin yok'}');
    if (granted != _permission) _dispatchPermission(granted);
    return granted;
  }

  void addPermissionObserver(void Function(bool permission) observer) {
    _permissionObservers.add(observer);
    CoreCloudNotification._log('permission observer eklendi (toplam ${_permissionObservers.length})');
  }

  void removePermissionObserver(void Function(bool permission) observer) {
    _permissionObservers.remove(observer);
    CoreCloudNotification._log('permission observer kaldırıldı (toplam ${_permissionObservers.length})');
  }

  /// Bildirime dokunulunca. Uygulama bildirimle soğuk açıldıysa, ilk listener eklendiği anda o
  /// tıklama da teslim edilir.
  void addClickListener(void Function(CoreNotificationClickEvent event) listener) {
    _clickListeners.add(listener);
    CoreCloudNotification._log('click listener eklendi (toplam ${_clickListeners.length})');
    if (_clickListeners.length == 1) unawaited(CoreCloudNotification._invoke<void>('setClickListener', <String, Object?>{'active': true}));
  }

  void removeClickListener(void Function(CoreNotificationClickEvent event) listener) {
    if (!_clickListeners.remove(listener)) return;
    CoreCloudNotification._log('click listener kaldırıldı (toplam ${_clickListeners.length})');
    if (_clickListeners.isNotEmpty) return;
    unawaited(CoreCloudNotification._invoke<void>('setClickListener', <String, Object?>{'active': false}));
  }

  /// Uygulama ön plandayken bildirim gelince, gösterilmeden önce.
  void addForegroundWillDisplayListener(void Function(CoreNotificationWillDisplayEvent event) listener) {
    _willDisplayListeners.add(listener);
    CoreCloudNotification._log('foregroundWillDisplay listener eklendi (toplam ${_willDisplayListeners.length})');
    if (_willDisplayListeners.length == 1) unawaited(CoreCloudNotification._invoke<void>('setWillDisplayListener', <String, Object?>{'active': true}));
  }

  void removeForegroundWillDisplayListener(void Function(CoreNotificationWillDisplayEvent event) listener) {
    if (!_willDisplayListeners.remove(listener)) return;
    CoreCloudNotification._log('foregroundWillDisplay listener kaldırıldı (toplam ${_willDisplayListeners.length})');
    if (_willDisplayListeners.isNotEmpty) return;
    unawaited(CoreCloudNotification._invoke<void>('setWillDisplayListener', <String, Object?>{'active': false}));
  }

  /// `preventDefault()` ile engellenmiş bildirimi gösterir.
  Future<void> displayNotification(String notificationId) => CoreCloudNotification._invoke<void>('displayNotification', <String, Object?>{'notificationId': notificationId});

  /// Bildirim merkezindeki tüm bildirimleri siler; iOS'ta badge'i sıfırlar.
  Future<void> clearAll() => CoreCloudNotification._invoke<void>('clearAll');

  Future<void> _refreshPermission() async {
    final granted = await CoreCloudNotification._invoke<bool>('permission') ?? false;
    if (granted != _permission) _dispatchPermission(granted);
  }

  bool _dispatchWillDisplay(CoreNotification notification) {
    final event = CoreNotificationWillDisplayEvent(notification);
    CoreCloudNotification._log('foregroundWillDisplay: ${notification.notificationId} "${notification.title ?? ''}" → ${_willDisplayListeners.length} listener');
    for (final listener in List.of(_willDisplayListeners)) {
      _guard(() => listener(event));
    }
    CoreCloudNotification._log('foregroundWillDisplay kararı: ${event.isPrevented ? 'engellendi (preventDefault)' : 'gösterilecek'}');
    return !event.isPrevented;
  }

  void _dispatchClick(CoreNotificationClickEvent event) {
    CoreCloudNotification._log(
      'click: ${event.notification.notificationId} actionId=${event.result.actionId} url=${event.result.url} '
      'additionalData=${event.notification.additionalData} → ${_clickListeners.length} listener',
    );
    for (final listener in List.of(_clickListeners)) {
      _guard(() => listener(event));
    }
  }

  void _dispatchPermission(bool granted) {
    CoreCloudNotification._log('izin değişti: $_permission → $granted (${_permissionObservers.length} observer)');
    _permission = granted;
    for (final observer in List.of(_permissionObservers)) {
      _guard(() => observer(granted));
    }
  }

  void _reset() {
    _clickListeners.clear();
    _willDisplayListeners.clear();
    _permissionObservers.clear();
    _permission = false;
  }
}

/// `CoreCloudNotification.User` (OneSignal `OneSignal.User`).
final class CoreCloudNotificationUser {
  CoreCloudNotificationUser._();

  final CoreCloudNotificationPushSubscription pushSubscription = CoreCloudNotificationPushSubscription._();

  Future<void> addTag(String key, Object value) => addTags(<String, Object>{key: value});

  /// Değerler string'e çevrilir (backend tag değerleri string). Sayısal karşılaştırma için de
  /// sayı string olarak gönderilir.
  Future<void> addTags(Map<String, dynamic> tags) => CoreCloudNotification._invoke<void>('addTags', <String, Object?>{
    'tags': <String, String>{for (final entry in tags.entries) entry.key: '${entry.value}'},
  });

  Future<void> removeTag(String key) => removeTags(<String>[key]);

  Future<void> removeTags(List<String> keys) => CoreCloudNotification._invoke<void>('removeTags', <String, Object?>{'keys': keys});

  /// Cihazdaki son bilinen tag'ler.
  Future<Map<String, String>> getTags() async => (await CoreCloudNotification._invoke<Map<Object?, Object?>>('getTags'))?.map((key, value) => MapEntry('$key', '$value')) ?? <String, String>{};

  /// Bildirim dilini cihaz dili yerine bununla belirler (iki harfli kod, ör. `tr`, `en`).
  Future<void> setLanguage(String language) => CoreCloudNotification._invoke<void>('setLanguage', <String, Object?>{'language': language});

  Future<String?> getExternalId() => CoreCloudNotification._invoke<String>('getExternalId');

  /// Backend'deki cihaz kaydının id'si (OneSignal'daki `onesignalId` yerine).
  Future<String?> getDeviceId() async => (await pushSubscription._refresh()).id;

  /// Cihaz kaydına e-posta ekler (panelde aramada ve segmentte kullanılır). Küçük harfe çevrilir.
  Future<void> addEmail(String email) => CoreCloudNotification._invoke<void>('addEmail', <String, Object?>{'email': email});

  /// Kayıttaki e-posta buysa siler.
  Future<void> removeEmail(String email) => CoreCloudNotification._invoke<void>('removeEmail', <String, Object?>{'email': email});

  /// Backend'de SMS kanalı yok; şimdilik hiçbir şey yapmaz.
  Future<void> addSms(String smsNumber) async => _unsupported('addSms');

  Future<void> removeSms(String smsNumber) async => _unsupported('removeSms');

  /// `externalUserId` dışında ek kimlik (ör. `crmId`); backend bu kimlikle hedefleyebilir.
  /// Cihaz başına en fazla 20 alias.
  Future<void> addAlias(String label, String id) => addAliases(<String, String>{label: id});

  Future<void> addAliases(Map<String, String> aliases) => CoreCloudNotification._invoke<void>('addAliases', <String, Object?>{'aliases': aliases});

  Future<void> removeAlias(String label) => removeAliases(<String>[label]);

  Future<void> removeAliases(List<String> labels) => CoreCloudNotification._invoke<void>('removeAliases', <String, Object?>{'labels': labels});

  /// Cihazdaki son bilinen alias'lar.
  Future<Map<String, String>> getAliases() async => (await CoreCloudNotification._invoke<Map<Object?, Object?>>('getAliases'))?.map((key, value) => MapEntry('$key', '$value')) ?? <String, String>{};

  void _unsupported(String method) => debugPrint('CoreCloudNotification.User.$method: backend desteklemiyor, çağrı yok sayıldı');
}

/// `CoreCloudNotification.User.pushSubscription` (OneSignal `OneSignal.User.pushSubscription`).
final class CoreCloudNotificationPushSubscription {
  CoreCloudNotificationPushSubscription._();

  CorePushSubscriptionState _current = const CorePushSubscriptionState();
  final _observers = <void Function(CorePushSubscriptionChangedState state)>[];

  /// Backend'deki cihaz id'si; kayıt olana kadar `null`.
  String? get id => _current.id;

  String? get token => _current.token;

  bool get optedIn => _current.optedIn;

  /// Uygulama içi bildirim aboneliğini açar (`subscribed: true`).
  Future<void> optIn() => CoreCloudNotification._invoke<void>('optIn');

  /// Uygulama içi bildirim aboneliğini kapatır (`subscribed: false`); izin olsa da bildirim gelmez.
  Future<void> optOut() => CoreCloudNotification._invoke<void>('optOut');

  void addObserver(void Function(CorePushSubscriptionChangedState state) observer) {
    _observers.add(observer);
    CoreCloudNotification._log('pushSubscription observer eklendi (toplam ${_observers.length})');
  }

  void removeObserver(void Function(CorePushSubscriptionChangedState state) observer) {
    _observers.remove(observer);
    CoreCloudNotification._log('pushSubscription observer kaldırıldı (toplam ${_observers.length})');
  }

  Future<CorePushSubscriptionState> _refresh() async {
    final map = await CoreCloudNotification._invoke<Map<Object?, Object?>>('getSubscription');
    if (map != null) _update(CorePushSubscriptionState.fromMap(map));
    return _current;
  }

  void _update(CorePushSubscriptionState state) {
    if (state == _current) return;
    CoreCloudNotification._log(
      'abonelik değişti: id ${_current.id} → ${state.id}, optedIn ${_current.optedIn} → ${state.optedIn}, '
      'token ${_current.token == state.token ? 'aynı' : 'değişti'} (${_observers.length} observer)',
    );
    final change = CorePushSubscriptionChangedState(previous: _current, current: state);
    _current = state;
    for (final observer in List.of(_observers)) {
      _guard(() => observer(change));
    }
  }
}

/// `CoreCloudNotification.Debug` (OneSignal `OneSignal.Debug`).
final class CoreCloudNotificationDebug {
  CoreCloudNotificationDebug._();

  /// Native log seviyesi (Android logcat `CoreCloudNotification`, iOS konsol `[CoreCloudNotification]`).
  /// `debug` ve üstünde Dart tarafındaki ayrıntılı loglar da açılır.
  Future<void> setLogLevel(CoreCloudNotificationLogLevel level) {
    CoreCloudNotification._logsEnabled = level.index >= CoreCloudNotificationLogLevel.debug.index;
    return CoreCloudNotification._invoke<void>('setLogLevel', <String, Object?>{'level': level.index});
  }

  /// OneSignal'daki görsel uyarı seviyesi; karşılığı yok.
  Future<void> setAlertLevel(CoreCloudNotificationLogLevel level) async {}
}

/// Uygulamanın listener'ındaki hata SDK'yı (ve diğer listener'ları) durdurmasın.
void _guard(void Function() body) {
  try {
    body();
  } catch (error, stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace, library: 'flutter_core/cloud_notification'));
  }
}
