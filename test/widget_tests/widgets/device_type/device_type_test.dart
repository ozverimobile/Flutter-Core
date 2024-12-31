import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceType Widget Test', () {
    testWidgets('DeviceType detects phone', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(DeviceType.deviceType, DeviceType.phone);
              return const Placeholder();
            },
          ),
        ),
      );
    });

    testWidgets('DeviceType detects tablet', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(DeviceType.deviceType, DeviceType.tablet);
              return const Placeholder();
            },
          ),
        ),
      );
    });

    testWidgets('DeviceType detects desktop', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1300);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(DeviceType.deviceType, DeviceType.desktop);
              return const Placeholder();
            },
          ),
        ),
      );
    });
  });
}
