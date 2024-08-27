import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const CoreTextExample());
}

class CoreTextExample extends StatelessWidget {
  const CoreTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ListView(
            children: const [
              CoreText.displayLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.displayMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.displaySmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.headlineLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.headlineMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.headlineSmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.titleLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.titleMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.titleSmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.bodyLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.bodyMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.bodySmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.labelLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.labelMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              CoreText.labelSmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.bold),
              verticalBox12,
              CoreText.displayLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.displayMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.displaySmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.headlineLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.headlineMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.headlineSmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.titleLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.titleMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.titleSmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.bodyLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.bodyMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.bodySmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.labelLarge('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.labelMedium('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
              CoreText.labelSmall('Hello World', textAlign: TextAlign.center, textColor: Colors.red, fontWeight: FontWeight.normal),
            ],
          ),
        ),
      ),
    );
  }
}
