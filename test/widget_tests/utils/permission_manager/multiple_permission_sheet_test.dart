import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _channel = MethodChannel('flutter.baseflow.com/permissions/methods');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();
  final manager = CorePermissionManager(navigatorKey: navigatorKey);

  /// System status of the camera permission; `requestPermissions` turns it into [requestAnswer].
  late PermissionStatus systemStatus;
  late PermissionStatus requestAnswer;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    systemStatus = PermissionStatus.denied;
    requestAnswer = PermissionStatus.granted;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          return systemStatus.index;
        case 'requestPermissions':
          systemStatus = requestAnswer;
          return {for (final p in call.arguments as List<Object?>) p: requestAnswer.index};
      }
      return null;
    });
  });

  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null));

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(MaterialApp(navigatorKey: navigatorKey, home: const Scaffold()));

  testWidgets('cancellable: close button returns null', (tester) async {
    await pumpApp(tester);
    Map<CorePermission, CorePermissionStatus>? result = const {};
    var completed = false;
    unawaited(manager.requestMultiplePermissionsCancellable(permissions: const [CorePermission.camera]).then((value) {
      result = value;
      completed = true;
    }));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(result, isNull);
  });

  testWidgets('cancellable: continue returns the statuses', (tester) async {
    await pumpApp(tester);
    Map<CorePermission, CorePermissionStatus>? result;
    unawaited(manager.requestMultiplePermissionsCancellable(permissions: const [CorePermission.camera]).then((value) => result = value));
    await tester.pumpAndSettle();

    await tester.tap(find.text('İzin Ver'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    expect(result, {CorePermission.camera: CorePermissionStatus.granted});
  });

  testWidgets('requestMultiplePermissions: close button still returns the statuses', (tester) async {
    await pumpApp(tester);
    Map<CorePermission, CorePermissionStatus>? result;
    unawaited(manager.requestMultiplePermissions(permissions: const [CorePermission.camera]).then((value) => result = value));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result, {CorePermission.camera: CorePermissionStatus.neverPrompted});
  });

  testWidgets('already granted: no sheet, statuses returned', (tester) async {
    systemStatus = PermissionStatus.granted;
    await pumpApp(tester);

    final result = await manager.requestMultiplePermissionsCancellable(permissions: const [CorePermission.camera]);

    expect(result, {CorePermission.camera: CorePermissionStatus.granted});
  });

  testWidgets('caption row is drawn only when eyebrow or eyebrowLeading is given', (tester) async {
    await pumpApp(tester);
    unawaited(manager.requestMultiplePermissionsCancellable(permissions: const [CorePermission.camera]));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('leading')), findsNothing);
    expect(find.text('Başlamadan önce'), findsOneWidget);
    expect(find.text('birkaç izin.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    unawaited(
      manager.requestMultiplePermissionsCancellable(
        permissions: const [CorePermission.camera],
        eyebrow: 'VALET · İZİNLER',
        eyebrowLeading: const SizedBox(key: ValueKey('leading')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VALET · İZİNLER'), findsOneWidget);
    expect(find.byKey(const ValueKey('leading')), findsOneWidget);
  });

  testWidgets('title without highlight stays a single line', (tester) async {
    await pumpApp(tester);
    unawaited(manager.requestMultiplePermissionsCancellable(permissions: const [CorePermission.camera], title: 'Gerekli İzinler'));
    await tester.pumpAndSettle();

    expect(find.text('Gerekli İzinler'), findsOneWidget);
    expect(find.text('birkaç izin.'), findsNothing);
  });

  testWidgets('description is replaced by the answer', (tester) async {
    requestAnswer = PermissionStatus.denied;
    await pumpApp(tester);
    unawaited(
      manager.requestMultiplePermissionsCancellable(
        permissions: const [CorePermission.camera],
        permissionDescriptions: const {CorePermission.camera: 'Araç fotoğrafı çekmek için'},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kamera'), findsOneWidget);
    expect(find.text('Araç fotoğrafı çekmek için'), findsOneWidget);

    await tester.tap(find.text('İzin Ver'));
    await tester.pumpAndSettle();

    expect(find.text('Araç fotoğrafı çekmek için'), findsNothing);
    expect(find.text('Reddedildi'), findsOneWidget);
  });

  testWidgets('denied forced permission: missing title and note, continue disabled', (tester) async {
    requestAnswer = PermissionStatus.permanentlyDenied;
    await pumpApp(tester);
    Map<CorePermission, CorePermissionStatus>? result;
    var completed = false;
    unawaited(
      manager.requestMultiplePermissionsCancellable(
        permissions: const [CorePermission.camera, CorePermission.photos],
        forcedPermissions: const {CorePermission.photos},
      ).then((value) {
        result = value;
        completed = true;
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zorunlu'), findsNWidgets(2), reason: 'row badge and note badge');

    await tester.tap(find.text('İzin Ver'));
    await tester.pumpAndSettle();

    expect(find.text('2 izin'), findsOneWidget);
    expect(find.text('eksik kaldı.'), findsOneWidget);
    expect(find.text('Gerekli'), findsOneWidget);
    expect(find.text('Ayarlara Git'), findsOneWidget);

    await tester.tap(find.text('Devam Et'));
    await tester.pumpAndSettle();

    expect(completed, isFalse);
    expect(result, isNull);
  });
}
