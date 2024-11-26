import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Set Text For Currency Format', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Handles empty input', () {
      controller.setTextForCurrencyFormat('');
      expect(controller.text, '');
    });

    test('Handles invalid input', () {
      controller.setTextForCurrencyFormat('test');
      expect(controller.text, '');
    });

    test('Handles valid input', () {
      controller.setTextForCurrencyFormat('1234');
      expect(controller.text, '1234,00');
    });

    test('Handles commas as decimal separators', () {
      controller.setTextForCurrencyFormat('123,456');
      expect(controller.text, '123,46');
    });

    test('Sets text for a valid number with custom fractionDigits', () {
      controller.setTextForCurrencyFormat('123.456', fractionDigits: 1);
      expect(controller.text, '123,5');
    });
  });
}
