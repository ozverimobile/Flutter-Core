import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';

/// This class contains the default input formatters
abstract class CoreDefaultInputFormatter {
  /// Currency formatter
  static TextInputFormatter creditCardExpiration() {
    return CoreInputFormatter(
      mask: '##/##',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  /// Credit Card formatter
  static TextInputFormatter creditCard() {
    return CoreInputFormatter(
      mask: '#### #### #### ####',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  /// Phone formatter
  static TextInputFormatter phoneNumber() {
    return CoreInputFormatter(
      mask: '(###) ### ## ##',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  /// Phone formatter By Type
  static TextInputFormatter phoneNumberByType(PhoneNumberFormat format) {
    return CoreInputFormatter(
      mask: format.mask,
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  /// Number formatter
  static TextInputFormatter number() => OnlyNumberFormatter();

  /// Lower Case formatter
  static TextInputFormatter lowerCase() => LowerCaseFormatter();

  /// Upper Case formatter
  static TextInputFormatter upperCase() => UpperCaseFormatter();

  /// Email formatter
  static TextInputFormatter email() => EmailFormatter();
}
