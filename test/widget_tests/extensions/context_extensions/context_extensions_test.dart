import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextExtension Tests', () {
    testWidgets('mediaQuerySize returns correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.mediaQuerySize, equals(const Size(800, 600)));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('height and width return correct values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.height, equals(600));
              expect(context.width, equals(800));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('safeAreaHeight calculates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.safeAreaHeight, equals(600));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('isDarkMode work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              expect(context.isDarkMode, false);
              expect(context.isLightMode, true);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('isLightMode work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              expect(context.isDarkMode, false);
              expect(context.isLightMode, true);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('mediaQueryPadding,mediaQuery,viewPadding,viewInsets,orientation ', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.mediaQueryPadding, MediaQuery.paddingOf(context));
              expect(context.mediaQuery, MediaQuery.of(context));
              expect(context.viewPadding, MediaQuery.viewPaddingOf(context));
              expect(context.viewInsets, MediaQuery.viewInsetsOf(context));
              expect(context.orientation, equals(Orientation.landscape));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('orientation checks work correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isPortrait, false);
              expect(context.isLandscape, true);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isPortrait, true);
              expect(context.isLandscape, false);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('locale and maybeLocale work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Builder(
            builder: (context) {
              expect(context.locale, const Locale('en', 'US'));
              expect(context.maybeLocale, const Locale('en', 'US'));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('isPhone, isTablet, and isDesktop classifications are correct', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isPhone, true);
              expect(context.isTablet, false);
              expect(context.isDesktop, false);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isPhone, false);
              expect(context.isTablet, true);
              expect(context.isDesktop, false);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      tester.view.physicalSize = const Size(1400, 1300);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isPhone, false);
              expect(context.isTablet, false);
              expect(context.isDesktop, true);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('isKeyboardOpen is open', (WidgetTester tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 100);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isKeyboardOpen, true);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('isKeyboardOpen is close', (WidgetTester tester) async {
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.isKeyboardOpen, false);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  testWidgets('flutterView returns correct view', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(context.flutterView, tester.view);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('devicePixelRatio returns correct value', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 2.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(context.devicePixelRatio, tester.view.devicePixelRatio);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('textScaler returns correct value', (WidgetTester tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(5)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              expect(context.textScaler, const TextScaler.linear(5));
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });

  testWidgets('directionality returns correct value', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(context.directionality, TextDirection.ltr);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) {
              expect(context.directionality, TextDirection.rtl);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });

  testWidgets('defaultTextStyle returns correct value', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(context.defaultTextStyle, DefaultTextStyle.of(context));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('usingBoldText returns correct value', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(context.usingBoldText, MediaQueryData.fromView(tester.view).boldText);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('topSafeAreaPadding returns correct value', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 24);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(context.topSafeAreaPadding, 24.0);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('bottomSafeAreaPadding returns correct value', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(bottom: 16);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(context.bottomSafeAreaPadding, 16.0);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('rebuildWidget triggers rebuild', (WidgetTester tester) async {
    var rebuildCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            rebuildCount++;
            return ElevatedButton(
              onPressed: context.rebuildWidget,
              child: const Text('Rebuild'),
            );
          },
        ),
      ),
    );

    expect(rebuildCount, 1);

    await tester.tap(find.text('Rebuild'));
    await tester.pump();

    expect(rebuildCount, 2);
  });
}
