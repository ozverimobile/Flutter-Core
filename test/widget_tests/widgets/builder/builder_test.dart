import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Builder Test', () {
    testWidgets('Should display and hide CircularProgressIndicator when loading state changes', (WidgetTester tester) async {
      await Core.initialize();
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return CoreBuilder(
              child: child,
            );
          },
          home: const Scaffold(
            body: Center(),
          ),
        ),
      );
      CoreBuilderController.showLoader();
      expect(CoreBuilderController.isShowLoadingNotifier.value, true);
      await tester.pump();
      final indicator = find.byType(CircularProgressIndicator);
      expect(indicator, findsOneWidget);
      CoreBuilderController.hideLoader();
      expect(CoreBuilderController.isShowLoadingNotifier.value, false);
      await tester.pump();
      expect(indicator, findsNothing);
    });

    testWidgets('Should close the keyboard when tapping outside the TextField', (WidgetTester tester) async {
      final focusNode = FocusNode();
      await Core.initialize();
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return CoreBuilder(
              child: child,
            );
          },
          home: Scaffold(
            body: Center(
              child: TextField(
                autofocus: true,
                focusNode: focusNode,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, true);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, false);
    });
  });
}
