import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DeviceType Widget Test', () {
    testWidgets('DeviceType detects phone', (tester) async {
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

    testWidgets('DeviceType detects tablet', (tester) async {
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

    testWidgets('DeviceType detects desktop', (tester) async {
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
