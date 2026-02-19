import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CoreRelativeHeight should calculate height based on percentage', (WidgetTester tester) async {
    const percentage = 0.5;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return const CoreRelativeHeight(percentage);
            },
          ),
        ),
      ),
    );

    final BuildContext context = tester.element(find.byType(CoreRelativeHeight));
    final expectedHeight = MediaQuery.of(context).size.height * percentage;

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));

    expect(sizedBox.height, equals(expectedHeight));
  });

  testWidgets('CoreRelativeWidth should calculate width based on percentage', (WidgetTester tester) async {
    const percentage = 0.3;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return const CoreRelativeWidth(percentage);
            },
          ),
        ),
      ),
    );

    final BuildContext context = tester.element(find.byType(CoreRelativeWidth));
    final expectedWidth = MediaQuery.of(context).size.width * percentage;

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));

    expect(sizedBox.width, equals(expectedWidth));
  });
}
