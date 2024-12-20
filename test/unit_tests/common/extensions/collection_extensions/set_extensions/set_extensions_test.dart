import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SetExtensionNullable Tests', () {
    Set<dynamic>? nullSet;

    setUp(() {
      nullSet = null;
    });
    group('isNullOrEmpty Group', () {
      test('isNullOrEmpty returns true for null set', () {
        expect(nullSet.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty returns true for empty set', () {
        nullSet = <int>{};
        expect(nullSet.isNullOrEmpty, isTrue);
        nullSet = <String>{};
        expect(nullSet.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty returns false for non-empty set', () {
        nullSet= <int>{1, 2, 3};
        expect(nullSet.isNullOrEmpty, isFalse);
        nullSet = <String>{'test', 'test2', 'test3'};
        expect(nullSet.isNullOrEmpty, isFalse);
      });
    });

    group('isNotNullAndNotEmpty Group', () {
      test('isNotNullAndNotEmpty returns false for null set', () {
        expect(nullSet.isNotNullAndNotEmpty, isFalse);
      });

      test('isNotNullAndNotEmpty returns false for empty set', () {
        nullSet = <int>{};
        expect(nullSet.isNotNullAndNotEmpty, isFalse);
        nullSet = <String>{};
        expect(nullSet.isNotNullAndNotEmpty, isFalse);
      });

      test('isNotNullAndNotEmpty returns true for non-empty set', () {
        nullSet = <int>{1, 2, 3};
        expect(nullSet.isNotNullAndNotEmpty, isTrue);
        nullSet = <String>{'test', 'test2', 'test3'};
        expect(nullSet.isNotNullAndNotEmpty, isTrue);
      });
    });
  });
}
