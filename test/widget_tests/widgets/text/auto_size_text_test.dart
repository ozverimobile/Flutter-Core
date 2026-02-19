import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'CoreAutoSizeText Test',
    () {
      testWidgets('Auto Shrink', (tester) async {
        await _validate(
          tester: tester,
          widget: const SizedBox(
            height: 200,
            width: 200,
            child: CoreAutoSizeText(
              'Accept',
              maxLines: 1,
              style: TextStyle(fontSize: 80),
            ),
          ),
          expectedFontSize: 33,
        );
      });
      testWidgets('Auto Shrink', (tester) async {
        await _validate(
          tester: tester,
          widget: const SizedBox(
            height: 200,
            width: 350,
            child: CoreAutoSizeText(
              'Accept',
              maxLines: 1,
              style: TextStyle(fontSize: 500),
            ),
          ),
          expectedFontSize: 57.75,
        );
      });

      testWidgets('Auto Shrink', (tester) async {
        await _validate(
          tester: tester,
          widget: const SizedBox(
            height: 200,
            width: 350,
            child: CoreAutoSizeText(
              'Accept',
              maxLines: 1,
              minFontSize: 100,
              style: TextStyle(fontSize: 500),
            ),
          ),
          expectedFontSize: 100,
        );
      });
      testWidgets('Auto Shrink', (tester) async {
        await _validate(
          tester: tester,
          widget: SizedBox(
            height: 200,
            width: 350,
            child: CoreAutoSizeText(
              'Accept' * 99,
              maxLines: 2,
              style: const TextStyle(fontSize: 500),
            ),
          ),
          expectedFontSize: 12,
        );
      });
      testWidgets(
        'Auto Shrink',
        (tester) async {
          await _validate(
            tester: tester,
            widget: SizedBox(
              height: 200,
              width: 350,
              child: CoreAutoSizeText(
                'Accept' * 5,
                maxLines: 3,
                minFontSize: 24,
                style: const TextStyle(fontSize: 60),
              ),
            ),
            expectedFontSize: 34.68,
          );
        },
      );
      testWidgets(
        'Auto Shrink Rich',
        (tester) async {
          await _validate(
            tester: tester,
            widget: SizedBox(
              height: 200,
              width: 350,
              child: CoreAutoSizeText.rich(
                TextSpan(text: 'Accept' * 5),
                maxLines: 3,
                minFontSize: 24,
                style: const TextStyle(fontSize: 60),
              ),
            ),
            expectedFontSize: 34.68,
          );
        },
      );
    },
  );
}

Future<void> _validate({required WidgetTester tester, required Widget widget, required double expectedFontSize}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: widget,
        ),
      ),
    ),
  );

  final renderObject = tester.renderObject<CoreASTRenderObject>(find.byType(CoreAutoSizeText));
  final fontSize = renderObject.style.fontSize!;

  expect(nearEqual(fontSize, expectedFontSize, 1), true);
}
