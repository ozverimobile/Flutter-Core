import 'package:flutter/material.dart';
import 'package:flutter_core/src/utils/input_formatter/input_formatters.dart';

const String _trCountryCode = '90';
const String _trCarrierPrefix = '5';

enum PhoneNumberFormat {
  /// 555 555 55 55
  plain,

  /// (555) 555 55 55
  withParens,

  /// +90 (555) 555 55 55
  withCountryParens,

  /// +90 (555) 555 55 55 with prefix +90 (5
  prefixWithCountryParens,

  /// +90 555 555 55 55
  withCountry,

  /// +90 555 555 55 55 with prefix +90 5
  prefixWithCountry,

  /// 0 (555) 555 55 55
  withZeroParens,

  /// 0 (555) 555 55 55 with prefix 0 (5
  /// ONLY WORK FOR TURKEY COUNTRY CODE
  prefixWithZeroParens,

  /// 0 555 555 55 55
  withZero,

  /// 0 555 555 55 55 with prefix 0
  /// ONLY WORK FOR TURKEY COUNTRY CODE
  prefixWithZero;

  String get mask {
    return switch (this) {
      PhoneNumberFormat.plain => '### ### ## ##',
      PhoneNumberFormat.withParens => '(###) ### ## ##',
      PhoneNumberFormat.withCountryParens => '+## (###) ### ## ##',
      PhoneNumberFormat.withCountry => '+## ### ### ## ##',
      PhoneNumberFormat.withZeroParens => '0 (###) ### ## ##',
      PhoneNumberFormat.withZero => '0 ### ### ## ##',
      PhoneNumberFormat.prefixWithCountryParens => '##) ### ## ##',
      PhoneNumberFormat.prefixWithCountry => '## ### ## ##',
      PhoneNumberFormat.prefixWithZeroParens => '##) ### ## ##',
      PhoneNumberFormat.prefixWithZero => '(###) ### ## ##',
    };
  }

  String? _prefix(String countryCode, String carrierPrefix) {
    return switch (this) {
      PhoneNumberFormat.prefixWithCountryParens => '+$countryCode ($carrierPrefix',
      PhoneNumberFormat.prefixWithCountry => '+$countryCode $carrierPrefix',
      PhoneNumberFormat.prefixWithZeroParens when countryCode == _trCountryCode => '0 ($carrierPrefix',
      PhoneNumberFormat.prefixWithZero when countryCode == _trCountryCode => '0 $carrierPrefix',
      _ => null,
    };
  }
}

@immutable
class CorePhoneNumberTextField extends StatelessWidget {
  const CorePhoneNumberTextField({
    this.controller,
    this.validator,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.autovalidateMode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.textInputAction,
    this.prefixIcon,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.buildCounter,
    this.enabled,
    this.focusNode,
    this.autofillHints,
    this.format = PhoneNumberFormat.withCountryParens,
    this.countryCode = _trCountryCode,
    this.carrierPrefix = _trCarrierPrefix,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.enableInteractiveSelection = false,
    super.key,
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final String? hintText;
  final String? labelText;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final bool? enabled;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final PhoneNumberFormat format;
  final String countryCode;
  final String carrierPrefix;
  final FloatingLabelBehavior floatingLabelBehavior;
  final bool enableInteractiveSelection;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enableInteractiveSelection: enableInteractiveSelection,
      controller: controller,
      enabled: enabled,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      textAlign: textAlign,
      autovalidateMode: autovalidateMode,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      keyboardType: TextInputType.phone,
      maxLength: maxLength,
      buildCounter: buildCounter,
      autofillHints: autofillHints,
      inputFormatters: [
        CoreDefaultInputFormatter.phoneNumberByType(format),
      ],
      decoration: InputDecoration(
        floatingLabelBehavior: floatingLabelBehavior,
        prefixText: format._prefix(countryCode, carrierPrefix),
        prefixIcon: prefixIcon,
        hintText: hintText,
        labelText: labelText,
      ),
    );
  }
}
