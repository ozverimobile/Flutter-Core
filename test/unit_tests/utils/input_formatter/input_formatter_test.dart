import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/utils/input_formatter/input_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoreInputFormatter Tests', () {
    test('Initializes with default mask and filter', () {
      final formatter = CoreInputFormatter(
        mask: '#/#',
      );

      // Test initial masked text
      expect(formatter.getMaskedText(), '');
      expect(formatter.getUnmaskedText(), '');
    });

    test('Correctly formats number input with mask "#/#"', () {
      final formatter = CoreInputFormatter(mask: '#/#');

      var text = const TextEditingValue(text: '1');
      var formatted = formatter.formatEditUpdate(TextEditingValue.empty, text);

      expect(formatted.text, '1');

      text = const TextEditingValue(text: '12');
      formatted = formatter.formatEditUpdate(TextEditingValue.empty, text);

      expect(formatted.text, '1/2');
    });

    test('Handles eager auto-completion for mask "#/#"', () {
      final formatter = CoreInputFormatter.eager(mask: '#/#');

      var text = const TextEditingValue(text: '1');
      var formatted = formatter.formatEditUpdate(TextEditingValue.empty, text);

      expect(formatted.text, '1/');

      text = const TextEditingValue(text: '12');
      formatted = formatter.formatEditUpdate(TextEditingValue.empty, text);

      expect(formatted.text, '1/2');
    });

    test('Test Credit Card Mask', () {
      final formatter = CoreDefaultInputFormatter.creditCard();

      const creditCardNo = TextEditingValue(text: '1234567890123456');
      final formatted = formatter.formatEditUpdate(TextEditingValue.empty, creditCardNo);

      expect(formatted.text, '1234 5678 9012 3456');

      const invalidCreditCardNo = TextEditingValue(text: '123456789012345');
      final invalidFormatted = formatter.formatEditUpdate(TextEditingValue.empty, invalidCreditCardNo);

      expect(invalidFormatted.text, '1234 5678 9012 345');
    });

    test('Test Credit Card Expiration Mask', () {
      final formatter = CoreDefaultInputFormatter.creditCardExpiration();

      const expiration = TextEditingValue(text: '1223');
      final formatted = formatter.formatEditUpdate(TextEditingValue.empty, expiration);

      expect(formatted.text, '12/23');

      const invalidExpiretion = TextEditingValue(text: '122');
      final invalidFormatted = formatter.formatEditUpdate(TextEditingValue.empty, invalidExpiretion);

      expect(invalidFormatted.text, '12/2');
    });

    test('Test Phone Number Mask', () {
      final formatter = CoreDefaultInputFormatter.phoneNumber();

      const phoneNumber = TextEditingValue(text: '1234567890');
      final formatted = formatter.formatEditUpdate(TextEditingValue.empty, phoneNumber);

      expect(formatted.text, '123 456 78 90');

      const invalidPhoneNumber = TextEditingValue(text: '123456789');
      final invalidFormatted = formatter.formatEditUpdate(TextEditingValue.empty, invalidPhoneNumber);

      expect(invalidFormatted.text, '123 456 78 9');
    });
  });
}
