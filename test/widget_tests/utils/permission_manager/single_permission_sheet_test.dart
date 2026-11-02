import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _channel = MethodChannel('flutter.baseflow.com/permissions/methods');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();
  final manager = CorePermissionManager(navigatorKey: navigatorKey);

  /// System status of the microphone permission; `requestPermissions` turns it into [requestAnswer].
  late PermissionStatus systemStatus;
  late PermissionStatus requestAnswer;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(appName: 'Test', packageName: 'test', version: '1', buildNumber: '1', buildSignature: '');
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

  testWidgets('asks with the default title and returns the answer', (tester) async {
    await pumpApp(tester);
    CorePermissionStatus? result;
    unawaited(manager.requestPermission(permission: CorePermission.microphone).then((value) => result = value));
    await tester.pumpAndSettle();

    expect(find.text('Mikrofon izni'), findsOneWidget);
    expect(find.text('gerekiyor.'), findsOneWidget);

    await tester.tap(find.text('İzin Ver'));
    await tester.pumpAndSettle();

    expect(result, CorePermissionStatus.granted);
  });

  testWidgets('close button returns neverPrompted', (tester) async {
    await pumpApp(tester);
    CorePermissionStatus? result;
    unawaited(manager.requestPermission(permission: CorePermission.microphone).then((value) => result = value));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result, CorePermissionStatus.neverPrompted);
  });

  testWidgets('permanently denied: explains it and offers the settings', (tester) async {
    systemStatus = PermissionStatus.permanentlyDenied;
    await pumpApp(tester);
    unawaited(manager.requestPermission(permission: CorePermission.microphone));
    await tester.pumpAndSettle();

    expect(find.text('kapalı.'), findsOneWidget);
    expect(find.text('Ayarlara Git'), findsOneWidget);
    expect(find.text('İzin Ver'), findsNothing);
  });

  testWidgets('a given title stays a single line', (tester) async {
    await pumpApp(tester);
    unawaited(manager.requestPermission(permission: CorePermission.location, title: 'Konum gerekli'));
    await tester.pumpAndSettle();

    expect(find.text('Konum gerekli'), findsOneWidget);
    expect(find.text('gerekiyor.'), findsNothing);
  });
}
