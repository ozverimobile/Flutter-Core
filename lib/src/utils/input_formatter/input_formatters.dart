import 'package:flutter_core/flutter_core.dart';

abstract class CoreInputformatter {
  CoreInputformatter._();

  static CoreInputFormatter creditCardExpiration() {
    return CoreInputFormatter(
      mask: '##/##',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  static CoreInputFormatter creditCard() {
    return CoreInputFormatter(
      mask: '#### #### #### ####',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }

  static CoreInputFormatter phoneNumber() {
    return CoreInputFormatter(
      mask: '### ### ## ##',
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
  }
}
