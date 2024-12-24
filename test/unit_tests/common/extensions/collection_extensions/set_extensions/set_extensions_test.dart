import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SetExtensionNullable Tests', () {
    Set<dynamic>? nullSet;

    group('isNullOrEmpty Group', () {
      test('isNullOrEmpty returns true for null set', () {
        expect(nullSet.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty returns true for empty set', () {
        expect(<int>{}.isNullOrEmpty, isTrue);
        expect(<String>{}.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty returns false for non-empty set', () {
        expect(<int>{1, 2, 3}.isNullOrEmpty, isFalse);
        expect(<String>{'test', 'test2', 'test3'}.isNullOrEmpty, isFalse);
      });
    });

    group('isNotNullAndNotEmpty Group', () {
      test('isNotNullAndNotEmpty returns false for null set', () {
        expect(nullSet.isNotNullAndNotEmpty, isFalse);
      });

      test('isNotNullAndNotEmpty returns false for empty set', () {
        expect(<int>{}.isNotNullAndNotEmpty, isFalse);
        expect(<String>{}.isNotNullAndNotEmpty, isFalse);
      });

      test('isNotNullAndNotEmpty returns true for non-empty set', () {
        expect(<int>{1, 2, 3}.isNotNullAndNotEmpty, isTrue);
        expect(<String>{'test', 'test2', 'test3'}.isNotNullAndNotEmpty, isTrue);
      });
    });
  });
}
