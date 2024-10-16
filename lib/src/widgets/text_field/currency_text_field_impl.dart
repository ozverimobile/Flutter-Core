import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
class CoreCurrencyTextField extends StatefulWidget {
  const CoreCurrencyTextField({
    this.controller,
    this.readOnly = false,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.autovalidateMode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.buildCounter,
    this.textFixed = 2,
    this.enabled,
    this.autofillHints,
    super.key,
  });

  final TextEditingController? controller;
  final bool readOnly;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? labelText;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final int textFixed;
  final bool? enabled;
  final Iterable<String>? autofillHints;

  @override
  State<CoreCurrencyTextField> createState() => _CoreCurrencyTextFieldState();
}

class _CoreCurrencyTextFieldState extends State<CoreCurrencyTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(focusNodeListener);
  }

  @override
  void dispose() {
    if (widget.controller.isNull) _controller.dispose();
    if (widget.focusNode.isNull) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: _controller,
      readOnly: widget.readOnly,
      focusNode: _focusNode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textAlign: widget.textAlign,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d*')),
      ],
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      maxLength: widget.maxLength,
      buildCounter: widget.buildCounter,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: widget.suffixIcon,
      ),
    );
  }

  void focusNodeListener() {
    if (_focusNode.hasFocus) {
      // FocusNode'a odaklandığında tüm metni seç
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else {
      // FocusNode'dan çıkıldığında metni düzenle
      _controller.setTextForCurrencyFormat(_controller.text, fractionDigits: widget.textFixed);
    }
  }
}
