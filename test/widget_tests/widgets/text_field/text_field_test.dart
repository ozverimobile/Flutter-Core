import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Core Credit Card Expiration TextField', () {
    testWidgets('Should allow input and format correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardExpirationTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardExpirationTextField), '1225');
      await tester.pump();
      expect(controller.text, '12/25');
    });

    testWidgets('Should not allow invalid characters in input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardExpirationTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardExpirationTextField), 'core');
      await tester.pump();
      expect(controller.text, '');
    });

    testWidgets('Should format numeric input as MM/YY and limit input to valid length', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardExpirationTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardExpirationTextField), '12345');
      await tester.pump();
      expect(controller.text, '12/34');
    });
  });

  group('Credit Card Security Code TextField', () {
    testWidgets('Should allow input and format correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardSecurityCodeTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardSecurityCodeTextField), '1234');
      await tester.pump();
      expect(controller.text, '1234');
    });

    testWidgets('Should test maxlength', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardSecurityCodeTextField(
              controller: controller,
              maxLength: 6,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardSecurityCodeTextField), '123456');
      await tester.pump();
      expect(controller.text, '123456');
    });

    testWidgets('Should not allow invalid characters in input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardSecurityCodeTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardSecurityCodeTextField), 'core');
      await tester.pump();
      expect(controller.text, '');
    });

    testWidgets('Should format numeric input and limit input to valid length', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardSecurityCodeTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardSecurityCodeTextField), '123456');
      await tester.pump();
      expect(controller.text, '1234');
    });
  });

  group('Core Credit Card Number TextField', () {
    testWidgets('Should allow input and format correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardTextField), '1234567890123456');
      await tester.pump();
      expect(controller.text, '1234 5678 9012 3456');
    });

    testWidgets('Should not allow invalid characters in input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardTextField), 'core');
      await tester.pump();
      expect(controller.text, '');
    });

    testWidgets('Should format numeric input and limit input to valid length', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCreditCardTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCreditCardTextField), '12345678901234567890');
      await tester.pump();
      expect(controller.text, '1234 5678 9012 3456');
    });
  });

  group('Core Currency TextField', () {
    testWidgets('Should allow input and format correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCurrencyTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCurrencyTextField), '1234,56');
      await tester.pump();
      expect(controller.text, '1234,56');
    });

    testWidgets('Should not allow invalid characters in input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreCurrencyTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CoreCurrencyTextField), 'core');
      await tester.pump();
      expect(controller.text, '');
    });
  });

  group('Core Password TextField', () {
    testWidgets('Should toggle obscureText and update the icon correctly', (WidgetTester tester) async {
      final textController = TextEditingController();

      // Widget'ı oluşturun
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CorePasswordTextField(
              controller: textController,
              suffixIcon: Icons.visibility_outlined,
              suffixIconOff: Icons.visibility_off_outlined,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(CorePasswordTextField), 'password123');
      await tester.pump();
      //BUTONA TIKLADIK OBSECURE FALSE YAPTIK
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      //TEXTFIELD I BULDUK VE OBSCURETEXT FALSE OLDUGUNU KONTROL ETTIK
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, false);
      //BUTONA TIKLADIK OBSECURE TRUE YAPTIK VE ICONUN DEĞİŞTİĞİNİ KONTROL ETTİK
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      final textField2 = tester.widget<TextField>(find.byType(TextField));
      expect(textField2.obscureText, true);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('Phone Number TextField', () {
    testWidgets('Should allow input and format correctly', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CorePhoneNumberTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CorePhoneNumberTextField), '1234567890');
      await tester.pump();
      expect(controller.text, '123 456 78 90');
    });

    testWidgets('Should not allow invalid characters in input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CorePhoneNumberTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CorePhoneNumberTextField), 'core');
      await tester.pump();
      expect(controller.text, '');
    });

    testWidgets('Should format numeric input and limit input to valid length', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CorePhoneNumberTextField(
              controller: controller,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CorePhoneNumberTextField), '12345678901234567890');
      await tester.pump();
      expect(controller.text, '123 456 78 90');
    });
  });

  group('Search TextField', () {
    testWidgets('Should show and hide the cancel button based on the text content', (WidgetTester tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreSearchTextField(
              controller: textController,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cancel), findsNothing);

      await tester.enterText(find.byType(CoreSearchTextField), 'Test');
      await tester.pump();

      expect(find.byIcon(Icons.cancel), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pump();

      expect(textController.text, isEmpty);

      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('Should trigger onChanged callback when text changes', (WidgetTester tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreSearchTextField(
              hintText: 'Search',
              onChanged: (value) {
                changedText = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(CoreSearchTextField), 'Test');
      await tester.pump();

      expect(changedText, equals('Test'));
    });
  });
}
