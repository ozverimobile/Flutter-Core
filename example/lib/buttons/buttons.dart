import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(
    const ButtonsExample(),
  );
}

class ButtonsExample extends StatelessWidget {
  const ButtonsExample({super.key});

  @override
  Widget build(BuildContext context) {
    const minButtonSize = Size(kMinInteractiveDimensionCupertino, kMinInteractiveDimensionCupertino);
    return MaterialApp(
      theme: ThemeData(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: minButtonSize,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: minButtonSize,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: minButtonSize,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: minButtonSize,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: minButtonSize,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CoreTextButton(
                onPressed: () {},
                child: const Text('Core Adaptive Text Button'),
              ),
              verticalBox8,
              CoreOutlinedButton(
                onPressed: () {},
                child: const Text('Core Adaptive Outlined Button'),
              ),
              verticalBox8,
              CoreFilledButton(
                onPressed: () {},
                child: CoreText.labelLarge(
                  'Core Adaptive Filled Button',
                  textColor: context.colorScheme.onPrimary,
                ),
              ),
              verticalBox8,
              CoreIconButton.filled(
                onPressed: () {},
                icon: Icon(
                  Icons.add,
                  color: context.colorScheme.onPrimary,
                ),
              ),
              CoreIconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.delete_forever,
                ),
              ),
              verticalBox8,
              CoreFilledButton.autoIndicator(
                indicatorStyle: const IndicatorStyle(
                  strokeWidth: 3,
                ),
                onPressed: 2.seconds.delay<void>,
                child: CoreText.labelLarge(
                  'Core Adaptive Filled Button with Auto Indicator',
                  textColor: context.colorScheme.onPrimary,
                ),
              ),
              verticalBox8,
              CoreTextButton.autoIndicator(
                indicatorStyle: const IndicatorStyle(
                  strokeWidth: 3,
                ),
                onPressed: 2.seconds.delay<void>,
                child: const CoreText.labelLarge(
                  'Core Text Button with Auto Indicator',
                ),
              ),
              CoreOutlinedButton.autoIndicator(
                indicatorStyle: const IndicatorStyle(
                  strokeWidth: 3,
                ),
                onPressed: 2.seconds.delay<void>,
                child: const CoreText.labelLarge(
                  'Core Outlined Button with Auto Indicator',
                ),
              ),
              verticalBox8,
              CoreIconButton.autoIndicator(
                indicatorStyle: const IndicatorStyle(
                  strokeWidth: 3,
                ),
                onPressed: 2.seconds.delay<void>,
                icon: const Icon(
                  Icons.delete_forever,
                ),
              ),
              verticalBox8,
              CoreIconButton.filledAutoIndicator(
                indicatorStyle: const IndicatorStyle(
                  strokeWidth: 3,
                ),
                onPressed: 2.seconds.delay<void>,
                icon: const Icon(
                  Icons.delete_forever,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
