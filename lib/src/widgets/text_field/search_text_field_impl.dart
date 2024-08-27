import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
class CoreSearchTextField extends StatefulWidget {
  const CoreSearchTextField({
    this.controller,
    this.validator,
    this.onChanged,
    this.autovalidateMode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.prefixIcon,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.buildCounter,
    this.enabled,
    this.focusNode,
    super.key,
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final String? hintText;
  final String? labelText;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final bool? enabled;
  final FocusNode? focusNode;

  @override
  State<CoreSearchTextField> createState() => _CoreSearchTextFieldState();
}

class _CoreSearchTextFieldState extends State<CoreSearchTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller.isNull) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cancelButtonVisible = _controller.text.isNotEmpty;

    return TextFormField(
      controller: _controller,
      validator: widget.validator,
      onChanged: (value) {
        widget.onChanged?.call(value);
        setState(() {
          cancelButtonVisible = value.isNotEmpty;
        });
      },
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      maxLength: widget.maxLength,
      buildCounter: widget.buildCounter,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: Visibility(
          visible: cancelButtonVisible,
          child: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              setState(_controller.clear);
              widget.onChanged?.call('');
            },
          ),
        ),
      ),
    );
  }
}
