import 'package:flutter/material.dart';

extension TextEditingControllerExtensions on TextEditingController {
  void setTextForCurrencyFormat(String text, {int fractionDigits = 2}) {
    final doubleValue = double.tryParse(text.replaceAll(',', '.'));
    this.text = (doubleValue?.toStringAsFixed(fractionDigits) ?? '').replaceAll('.', ',');
  }
}
