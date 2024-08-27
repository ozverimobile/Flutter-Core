import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class CoreCreditCardSecurityCodeTextField extends StatelessWidget {
  const CoreCreditCardSecurityCodeTextField({
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
    this.buildCounter,
    this.enabled,
    this.focusNode,
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
  final InputCounterWidgetBuilder? buildCounter;
  final bool? enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      focusNode: focusNode,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      textAlign: textAlign,
      autovalidateMode: autovalidateMode,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(4),
      ],
      buildCounter: buildCounter,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        labelText: labelText,
      ),
    );
  }
}
