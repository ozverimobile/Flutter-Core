import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoreSizedBox Tests', () {
    testWidgets('CoreSizedBox shrink and expand test', (WidgetTester tester) async {
      const shrinkBox = CoreSizedBox.shrink();
      const expandBox = CoreSizedBox.expand();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                shrinkBox,
                Expanded(child: expandBox),
              ],
            ),
          ),
        ),
      );

      expect(shrinkBox.width, 0.0);
      expect(shrinkBox.height, 0.0);

      final expandBoxSize = tester.getSize(find.byWidget(expandBox));
      expect(expandBoxSize.width, greaterThan(0));
      expect(expandBoxSize.height, greaterThan(0));
    });
    testWidgets('CoreSizedBox addition and subtraction test', (WidgetTester tester) async {
      const testSizedBox1 = CoreSizedBox(width: 50, height: 100);
      const testSizedBox2 = CoreSizedBox(width: 30, height: 70);

      final sumSizedBox = testSizedBox1 + testSizedBox2;
      final diffSizedBox = testSizedBox1 - testSizedBox2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                sumSizedBox,
                diffSizedBox,
              ],
            ),
          ),
        ),
      );

      expect(sumSizedBox.width, 80);
      expect(sumSizedBox.height, 170);

      expect(diffSizedBox.width, 20);
      expect(diffSizedBox.height, 30);
    });
  });
}
