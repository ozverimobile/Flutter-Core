import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Responsive_Layout Tests', () {
    testWidgets('CoreResponsiveLayout shows correct layout for phone', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: CoreResponsiveLayout(
            phone: (context) => const Text('Phone Layout'),
            tablet: (context) => const Text('Tablet Layout'),
            desktop: (context) => const Text('Desktop Layout'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Phone Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('CoreResponsiveLayout shows correct layout for tablet', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: CoreResponsiveLayout(
            phone: (context) => const Text('Phone Layout'),
            tablet: (context) => const Text('Tablet Layout'),
            desktop: (context) => const Text('Desktop Layout'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Phone Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('CoreResponsiveLayout shows correct layout for desktop', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 1300);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: CoreResponsiveLayout(
            phone: (context) => const Text('Phone Layout'),
            tablet: (context) => const Text('Tablet Layout'),
            desktop: (context) => const Text('Desktop Layout'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Phone Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsOneWidget);
    });
  });
}
