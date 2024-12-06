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

  /// Currency formatter
  static TextInputFormatter creditCard() {
    return CoreInputFormatter(
      mask: '#### #### #### ####',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  /// Currency formatter
  static TextInputFormatter phoneNumber() {
    return CoreInputFormatter(
      mask: '### ### ## ##',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  /// Currency formatter
  static TextInputFormatter number() => OnlyNumberFormatter();

  /// Currency formatter
  static TextInputFormatter lowerCase() => LowerCaseFormatter();

  /// Currency formatter
  static TextInputFormatter upperCase() => UpperCaseFormatter();

  /// Currency formatter
  static TextInputFormatter email() => EmailFormatter();
}
