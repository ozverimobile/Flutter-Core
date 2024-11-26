import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(
    const TextFieldsExample(),
  );
}

final class TextFieldsExample extends StatelessWidget {
  const TextFieldsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CorePasswordTextField(hintText: 'Password'),
                verticalBox8,
                CorePasswordTextField(hintText: 'RePassword'),
                verticalBox8,
                CorePhoneNumberTextField(hintText: 'Phone'),
                verticalBox8,
                CoreSearchTextField(hintText: 'Search'),
                verticalBox8,
                CoreCurrencyTextField(hintText: 'Currency'),
                verticalBox8,
                CoreCreditCardTextField(hintText: 'Credit Card'),
                verticalBox8,
                CoreCreditCardExpirationTextField(hintText: 'Expiration'),
                verticalBox8,
                CoreCreditCardSecurityCodeTextField(hintText: 'Security Code'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
