import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_core/cloud_notification');
  final calls = <MethodCall>[];

  Future<Object?> fromNative(String method, Object? arguments) async {
    final replies = <Object?>[];
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments)),
      (data) => replies.add(data == null ? null : const StandardMethodCodec().decodeEnvelope(data)),
    );
    return replies.single;
  }

  Map<String, Object?> notification({Object? additionalData}) => <String, Object?>{
    'notificationId': 'nid-1',
    'title': 'Siparişin yolda',
    'body': 'Kargoya verildi',
    'additionalData': additionalData ?? <String, Object?>{},
  };

  setUp(() {
    calls.clear();
    CoreCloudNotification.debugReset();
    CoreCloudNotification.debugIsSupported = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'permission':
        case 'requestPermission':
          return true;
        case 'getSubscription':
          return <String, Object?>{'id': 'device-1', 'token': 'tok', 'optedIn': true};
      }
      return null;
    });
  });

  tearDown(() => CoreCloudNotification.debugIsSupported = null);

  group('notification', () {
    test('additionalData boşsa null, iç içe nesneler Map<String, dynamic>', () {
      expect(CoreNotification.fromMap(notification()).additionalData, isNull);

      final parsed = CoreNotification.fromMap(notification(additionalData: <Object?, Object?>{
        'type': 'Meeting',
        'data': <Object?, Object?>{'id': '5', 'tags': <Object?>[1, <Object?, Object?>{'a': true}]},
      }));
      final data = parsed.additionalData!;
      expect(data['type'], 'Meeting');
      expect(data['data'], isA<Map<String, dynamic>>());
      expect((data['data'] as Map<String, dynamic>)['id'], '5');
      expect(((data['data'] as Map)['tags'] as List)[1], isA<Map<String, dynamic>>());
    });
  });

  group('foreground', () {
    test('listener yoksa ve preventDefault çağrılmazsa gösterilir', () async {
      // Dart henüz kanalı dinlemiyorsa cevap null; native taraf false dışındaki her cevabı "göster" sayar.
      expect(await fromNative('onWillDisplay', notification()), isNot(false));
      CoreCloudNotification.Notifications.addForegroundWillDisplayListener((_) {});
      expect(await fromNative('onWillDisplay', notification()), isTrue);
      expect(calls.where((c) => c.method == 'setWillDisplayListener').single.arguments, {'active': true});
    });

    test('preventDefault gösterimi engeller, hata atan listener diğerlerini durdurmaz', () async {
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = errors.add;
      CoreCloudNotification.Notifications
        ..addForegroundWillDisplayListener((_) => throw StateError('uygulama hatası'))
        ..addForegroundWillDisplayListener((event) => event.preventDefault());
      expect(await fromNative('onWillDisplay', notification()), isFalse);
      expect(errors, hasLength(1));
      FlutterError.onError = FlutterError.presentError;
    });

    test('display() native tarafa notificationId ile gider', () async {
      CoreCloudNotification.Notifications.addForegroundWillDisplayListener((event) {
        event.preventDefault();
        event.notification.display();
      });
      await fromNative('onWillDisplay', notification());
      expect(calls.last.method, 'displayNotification');
      expect(calls.last.arguments, {'notificationId': 'nid-1'});
    });
  });

  group('click', () {
    test('ilk listener native kuyruğu açar, son listener kapatır', () async {
      final received = <CoreNotificationClickEvent>[];
      void listener(CoreNotificationClickEvent event) => received.add(event);
      CoreCloudNotification.Notifications.addClickListener(listener);
      await fromNative('onClick', <String, Object?>{
        'notification': notification(additionalData: {'url': 'x'}),
        'result': <String, Object?>{'actionId': null, 'url': 'myapp://orders/42'},
      });
      CoreCloudNotification.Notifications.removeClickListener(listener);

      expect(received.single.notification.title, 'Siparişin yolda');
      expect(received.single.result.url, 'myapp://orders/42');
      expect(calls.where((c) => c.method == 'setClickListener').map((c) => c.arguments), [
        {'active': true},
        {'active': false},
      ]);
    });
  });

  group('buttons', () {
    test("butonlar ayrıştırılır, basılan butonun id ve url'i click sonucunda gelir", () async {
      final received = <CoreNotificationClickEvent>[];
      CoreCloudNotification.Notifications.addClickListener(received.add);
      await fromNative('onClick', <String, Object?>{
        'notification': <String, Object?>{
          ...notification(),
          'buttons': <Object?>[
            <String, Object?>{'id': 'approve', 'text': 'Onayla'},
            <String, Object?>{'id': 'reject', 'text': 'Reddet', 'url': 'myapp://reject'},
          ],
        },
        'result': <String, Object?>{'actionId': 'reject', 'url': 'myapp://reject'},
      });

      final event = received.single;
      expect(event.notification.buttons.map((b) => b.id), ['approve', 'reject']);
      expect(event.notification.buttons.last.url, 'myapp://reject');
      expect(event.result.actionId, 'reject');
      expect(event.result.url, 'myapp://reject');
    });
  });

  group('user', () {
    test('e-posta ve alias çağrıları native tarafa gider', () async {
      await CoreCloudNotification.User.addEmail('Ali@Ozdilek.com.tr');
      await CoreCloudNotification.User.addAlias('crmId', 'C-1001');
      await CoreCloudNotification.User.removeAliases(['eskiId']);
      await CoreCloudNotification.User.removeEmail('ali@ozdilek.com.tr');
      expect(calls.map((c) => [c.method, c.arguments]), [
        ['addEmail', {'email': 'Ali@Ozdilek.com.tr'}],
        ['addAliases', {'aliases': {'crmId': 'C-1001'}}],
        ['removeAliases', {'labels': ['eskiId']}],
        ['removeEmail', {'email': 'ali@ozdilek.com.tr'}],
      ]);
    });

    test('tag değerleri string olarak gider', () async {
      await CoreCloudNotification.User.addTags({'departmentId': 12, 'vip': true, 'name': 'Ali'});
      expect(calls.last.arguments, {
        'tags': {'departmentId': '12', 'vip': 'true', 'name': 'Ali'},
      });
    });

    test('initialize izin ve aboneliği okur, değişiklikte observer çağrılır', () async {
      final changes = <CorePushSubscriptionChangedState>[];
      CoreCloudNotification.User.pushSubscription.addObserver(changes.add);
      await CoreCloudNotification.initialize('app-1');

      expect(calls.first.arguments, {'appId': 'app-1', 'baseUrl': CoreCloudNotification.defaultBaseUrl, 'openLaunchUrls': true});
      expect(CoreCloudNotification.Notifications.permission, isTrue);
      expect(CoreCloudNotification.User.pushSubscription.id, 'device-1');
      expect(changes.single.current.optedIn, isTrue);

      await fromNative('onSubscriptionChanged', <String, Object?>{'id': 'device-1', 'token': 'tok', 'optedIn': false});
      expect(changes.last.previous.optedIn, isTrue);
      expect(CoreCloudNotification.User.pushSubscription.optedIn, isFalse);
    });
  });

  test('desteklenmeyen platformda çağrılar no-op', () async {
    CoreCloudNotification.debugIsSupported = false;
    await CoreCloudNotification.initialize('app-1');
    expect(await CoreCloudNotification.Notifications.requestPermission(true), isFalse);
    expect(calls, isEmpty);
  });
}
