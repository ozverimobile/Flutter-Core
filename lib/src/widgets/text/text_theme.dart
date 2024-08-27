import 'package:flutter/material.dart';

enum CoreTextTheme {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  labelLarge,
  labelMedium,
  labelSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
}

extension CoreTextThemeExtension on CoreTextTheme? {
  TextStyle? toTextStyle(BuildContext context) => switch (this) {
        CoreTextTheme.displayLarge => Theme.of(context).textTheme.displayLarge,
        CoreTextTheme.displayMedium => Theme.of(context).textTheme.displayMedium,
        CoreTextTheme.displaySmall => Theme.of(context).textTheme.displaySmall,
        CoreTextTheme.headlineLarge => Theme.of(context).textTheme.headlineLarge,
        CoreTextTheme.headlineMedium => Theme.of(context).textTheme.headlineMedium,
        CoreTextTheme.headlineSmall => Theme.of(context).textTheme.headlineSmall,
        CoreTextTheme.titleLarge => Theme.of(context).textTheme.titleLarge,
        CoreTextTheme.titleMedium => Theme.of(context).textTheme.titleMedium,
        CoreTextTheme.titleSmall => Theme.of(context).textTheme.titleSmall,
        CoreTextTheme.labelLarge => Theme.of(context).textTheme.labelLarge,
        CoreTextTheme.labelMedium => Theme.of(context).textTheme.labelMedium,
        CoreTextTheme.labelSmall => Theme.of(context).textTheme.labelSmall,
        CoreTextTheme.bodyLarge => Theme.of(context).textTheme.bodyLarge,
        CoreTextTheme.bodyMedium => Theme.of(context).textTheme.bodyMedium,
        CoreTextTheme.bodySmall => Theme.of(context).textTheme.bodySmall,
        _ => null,
      };
}
