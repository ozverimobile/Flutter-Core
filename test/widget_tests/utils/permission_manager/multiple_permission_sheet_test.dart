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
}
