import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Data Provider Test', () {
    testWidgets('Successful Scenario', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataProvider(
              data: 'Successful Scenario',
              child: Builder(
                builder: (context) {
                  return const _TestSubWidget();
                },
              ),
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(_TestSubWidget)) as BuildContext;
      expect(context.getDataProvider<String>(), 'Successful Scenario');
    });

    testWidgets('Not injected ', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return const _TestSubWidget();
              },
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(_TestSubWidget)) as BuildContext;
      expect(() => context.getDataProvider<String>(), throwsFlutterError);
    });

    testWidgets('Diffrence ', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataProvider(
              data: 'Successful Scenario',
              child: Builder(
                builder: (context) {
                  return const _TestSubWidget();
                },
              ),
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(_TestSubWidget)) as BuildContext;
      expect(() => context.getDataProvider<int>(), throwsFlutterError);
    });
  });
}

class _TestSubWidget extends StatelessWidget {
  const _TestSubWidget();

  @override
  Widget build(BuildContext context) {
    return const Center();
  }
}
