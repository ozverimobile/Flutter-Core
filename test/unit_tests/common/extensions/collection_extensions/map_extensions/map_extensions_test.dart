import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapExtensionNullable Tests', () {
    Map<String, dynamic>? nullableMap;

    group('isNullOrEmpty Group', () {
      test('isNullOrEmpty should return true for null map', () {
        expect(nullableMap.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty should return true for empty map', () {
        nullableMap = {};
        expect(nullableMap.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty should return false for non-empty map', () {
        expect({'key': 1}.isNullOrEmpty, isFalse);

        expect({'key': 'test'}.isNullOrEmpty, isFalse);

        expect(
          {
            'key': ['test', 'test'],
          }.isNullOrEmpty,
          isFalse,
        );

        expect({'key': null}.isNullOrEmpty, isFalse);
      });
    });
    group('isNotNullAndNotEmpty Group', () {
      test('isNotNullAndNotEmpty should return false for null map', () {
        expect(nullableMap.isNotNullAndNotEmpty, isFalse);
      });

      test('isNotNullAndNotEmpty should return false for empty map', () {
        nullableMap = {};
        expect(nullableMap.isNotNullAndNotEmpty, isFalse);
      });

      test('isNotNullAndNotEmpty should return true for non-empty map', () {
        expect({'key': 1}.isNotNullAndNotEmpty, isTrue);

        expect({'key': 'test'}.isNotNullAndNotEmpty, isTrue);

        expect(
          {
            'key': ['test', 'test'],
          }.isNotNullAndNotEmpty,
          isTrue,
        );

        expect({'key': null}.isNotNullAndNotEmpty, isTrue);
      });
    });
    group('notContainsKey Group', () {
      test('notContainsKey should return true for null map', () {
        expect(nullableMap.notContainsKey('key'), isTrue);
      });

      test('notContainsKey should return true for key not in map', () {
        expect({'key': 1}.notContainsKey('anotherKey'), isTrue);
      });

      test('notContainsKey should return false for key in map', () {
        expect({'key': 1}.notContainsKey('key'), isFalse);
      });

      test('notContainsKey should return true for null key', () {
        expect({'key': 1}.notContainsKey(null), isTrue);
      });
      test('notContainsKey should return true for map with null values for a missing key', () {
        expect({'key': null}.notContainsKey('missingKey'), isTrue);
      });
    });
    group('notContainsValue Group', () {
      test('notContainsValue should return true for null map', () {
        expect(nullableMap.notContainsValue(1), isTrue);
      });

      test('notContainsValue should return true for value not in map', () {
        expect({'key': 1}.notContainsValue(2), isTrue);

        expect({'key': 'test'}.notContainsValue('test2'), isTrue);

        expect(
          {
            'key': ['test', 'test'],
          }.notContainsValue(['test']),
          isTrue,
        );
      });

      test('notContainsValue should return false for value in map', () {
        expect({'key': 1}.notContainsValue(1), isFalse);

        expect({'key': 'test'}.notContainsValue('test'), isFalse);
      });
    });
  });
}
