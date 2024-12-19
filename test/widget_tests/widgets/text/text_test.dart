import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CoreText Tests',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CoreText(null),
                CoreText.bodySmall('bodySmall'),
                CoreText.bodyMedium('bodyMedium'),
                CoreText.bodyLarge('bodyLarge'),
                CoreText.displaySmall('displaySmall'),
                CoreText.displayMedium('displayMedium'),
                CoreText.displayLarge('displayLarge'),
                CoreText.headlineSmall('headlineSmall'),
                CoreText.headlineMedium('headlineMedium'),
                CoreText.headlineLarge('headlineLarge'),
                CoreText.labelSmall('labelSmall'),
                CoreText.labelMedium('labelMedium'),
                CoreText.labelLarge('labelLarge'),
                CoreText.titleSmall('titleSmall'),
                CoreText.titleMedium('titleMedium'),
                CoreText.titleLarge('titleLarge'),
              ],
            ),
          ),
        ),
      );

      final context = tester.element(find.text('bodySmall')) as BuildContext;
      final bodySmallTextStyle = tester.widget<Text>(find.text('bodySmall')).style;
      final bodyMediumTextStyle = tester.widget<Text>(find.text('bodyMedium')).style;
      final bodyLargeTextStyle = tester.widget<Text>(find.text('bodyLarge')).style;
      final displaySmallTextStyle = tester.widget<Text>(find.text('displaySmall')).style;
      final displayMediumTextStyle = tester.widget<Text>(find.text('displayMedium')).style;
      final displayLargeTextStyle = tester.widget<Text>(find.text('displayLarge')).style;
      final headlineSmallTextStyle = tester.widget<Text>(find.text('headlineSmall')).style;
      final headlineMediumTextStyle = tester.widget<Text>(find.text('headlineMedium')).style;
      final headlineLargeTextStyle = tester.widget<Text>(find.text('headlineLarge')).style;
      final labelSmallTextStyle = tester.widget<Text>(find.text('labelSmall')).style;
      final labelMediumTextStyle = tester.widget<Text>(find.text('labelMedium')).style;
      final labelLargeTextStyle = tester.widget<Text>(find.text('labelLarge')).style;
      final titleSmallTextStyle = tester.widget<Text>(find.text('titleSmall')).style;
      final titleMediumTextStyle = tester.widget<Text>(find.text('titleMedium')).style;
      final titleLargeTextStyle = tester.widget<Text>(find.text('titleLarge')).style;

      expect(bodySmallTextStyle, equals(context.textTheme.bodySmall));
      expect(bodyMediumTextStyle, equals(context.textTheme.bodyMedium));
      expect(bodyLargeTextStyle, equals(context.textTheme.bodyLarge));

      expect(displaySmallTextStyle, equals(context.textTheme.displaySmall));
      expect(displayMediumTextStyle, equals(context.textTheme.displayMedium));
      expect(displayLargeTextStyle, equals(context.textTheme.displayLarge));

      expect(headlineSmallTextStyle, equals(context.textTheme.headlineSmall));
      expect(headlineMediumTextStyle, equals(context.textTheme.headlineMedium));
      expect(headlineLargeTextStyle, equals(context.textTheme.headlineLarge));

      expect(labelSmallTextStyle, equals(context.textTheme.labelSmall));
      expect(labelMediumTextStyle, equals(context.textTheme.labelMedium));
      expect(labelLargeTextStyle, equals(context.textTheme.labelLarge));

      expect(titleSmallTextStyle, equals(context.textTheme.titleSmall));
      expect(titleMediumTextStyle, equals(context.textTheme.titleMedium));
      expect(titleLargeTextStyle, equals(context.textTheme.titleLarge));

      expect(bodySmallTextStyle, equals(CoreTextTheme.bodySmall.toTextStyle(context)));
      expect(bodyMediumTextStyle, equals(CoreTextTheme.bodyMedium.toTextStyle(context)));
      expect(bodyLargeTextStyle, equals(CoreTextTheme.bodyLarge.toTextStyle(context)));

      expect(displaySmallTextStyle, equals(CoreTextTheme.displaySmall.toTextStyle(context)));
      expect(displayMediumTextStyle, equals(CoreTextTheme.displayMedium.toTextStyle(context)));
      expect(displayLargeTextStyle, equals(CoreTextTheme.displayLarge.toTextStyle(context)));

      expect(headlineSmallTextStyle, equals(CoreTextTheme.headlineSmall.toTextStyle(context)));
      expect(headlineMediumTextStyle, equals(CoreTextTheme.headlineMedium.toTextStyle(context)));
      expect(headlineLargeTextStyle, equals(CoreTextTheme.headlineLarge.toTextStyle(context)));

      expect(labelSmallTextStyle, equals(CoreTextTheme.labelSmall.toTextStyle(context)));
      expect(labelMediumTextStyle, equals(CoreTextTheme.labelMedium.toTextStyle(context)));
      expect(labelLargeTextStyle, equals(CoreTextTheme.labelLarge.toTextStyle(context)));

      expect(titleSmallTextStyle, equals(CoreTextTheme.titleSmall.toTextStyle(context)));
      expect(titleMediumTextStyle, equals(CoreTextTheme.titleMedium.toTextStyle(context)));
      expect(titleLargeTextStyle, equals(CoreTextTheme.titleLarge.toTextStyle(context)));

      expect(find.byWidget(emptyBox), findsOneWidget);
    },
  );
}
