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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CorePasswordTextField(hintText: 'Password'),
                  verticalBox8,
                  CorePasswordTextField(hintText: 'RePassword'),
                  verticalBox8,
                  CorePhoneNumberTextField(
                    hintText: 'Phone',
                    format: PhoneNumberFormat.prefixWithZeroParens,
                  ),
                  verticalBox8,
                  _PhoneNumberWithCountryPicker(),
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
      ),
    );
  }
}

/// Ülke seçimli telefon alanı örneği.
class _PhoneNumberWithCountryPicker extends StatefulWidget {
  const _PhoneNumberWithCountryPicker();

  @override
  State<_PhoneNumberWithCountryPicker> createState() => _PhoneNumberWithCountryPickerState();
}

class _PhoneNumberWithCountryPickerState extends State<_PhoneNumberWithCountryPicker> {
  /// Ülke ve numarayı tek yerden okumak için özel controller.
  final CorePhoneNumberController _controller = CorePhoneNumberController(isoCode: 'TR');

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CorePhoneNumberTextField.withCountryPicker(
          controller: _controller,
          hintText: 'Phone with country',
          phoneNumberValidator: (phoneNumber) => phoneNumber.isValid ? null : 'Geçersiz numara',
          countryPickerOptions: const CoreCountryPickerOptions(
            favoriteIsoCodes: ['TR', 'US', 'DE'],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 12),
          child: Text(
            'text: ${_controller.text}\n'
            'country: ${_controller.country.isoCode} (${_controller.country.dialCodeWithPlus})\n'
            'completeNumber: ${_controller.completeNumber}\n'
            'isValid: ${_controller.isValid}',
          ),
        ),
      ],
    );
  }
}
