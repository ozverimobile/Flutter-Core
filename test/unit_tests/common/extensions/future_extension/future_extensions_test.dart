import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const startLoading = 'Start Loading';
  const testResult = 'Test Result';
  const testException = 'Test Exception';
  const runFuture = 'Run Future';
  const runFailingException = 'Run Failing Future';

  group('Future Extension Tests', () {
    group('FutureExtensions<T> - loading()', () {
      testWidgets('should show and hide loader correctly', (tester) async {
        var isLoaderShown = false;
        CoreBuilderController.isShowLoadingNotifier.addListener(() {
          isLoaderShown = CoreBuilderController.isShowLoadingNotifier.value;
        });

        final testWidget = MaterialApp(
          home: CoreBuilder(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 500)).loading();
                },
                child: const Text(startLoading),
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        await tester.tap(find.text(startLoading));
        await tester.pump();
        expect(isLoaderShown, isTrue);

        await tester.pump(const Duration(milliseconds: 500));
        expect(isLoaderShown, isFalse);
      });

      testWidgets('should execute future and return result', (tester) async {
        var result = '';
        final future = Future<String>.delayed(
          const Duration(milliseconds: 300),
          () => testResult,
        );

        final testWidget = MaterialApp(
          home: CoreBuilder(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await future.loading();
                },
                child: const Text(runFuture),
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        await tester.tap(find.text(runFuture));
        await tester.pump(const Duration(milliseconds: 300));

        expect(result, testResult);
      });
    });
    group('FutureExtensions<T> - loading() Failure Cases', () {
      testWidgets('should hide loader if future throws an error', (tester) async {
        var isLoaderShown = false;
        CoreBuilderController.isShowLoadingNotifier.addListener(() {
          isLoaderShown = CoreBuilderController.isShowLoadingNotifier.value;
        });

        final future = Future<void>.delayed(
          const Duration(milliseconds: 300),
          () => throw Exception(testException),
        );

        final testWidget = MaterialApp(
          home: CoreBuilder(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  try {
                    await future.loading();
                  } catch (_) {}
                },
                child: const Text(runFailingException),
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        await tester.tap(find.text(runFailingException));
        await tester.pump();
        expect(isLoaderShown, isTrue);

        await tester.pump(const Duration(milliseconds: 300));
        expect(isLoaderShown, isFalse);
      });

      testWidgets('should rethrow the error from the future', (tester) async {
        final future = Future<void>.delayed(
          const Duration(milliseconds: 300),
          () => throw Exception(testException),
        );

        String? errorMessage;

        final testWidget = MaterialApp(
          home: CoreBuilder(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  try {
                    await future.loading();
                  } catch (e) {
                    errorMessage = e.toString();
                  }
                },
                child: const Text(runFailingException),
              ),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        await tester.tap(find.text(runFailingException));
        await tester.pump(const Duration(milliseconds: 300));

        expect(errorMessage, contains(testException));
      });
    });
  });
}
