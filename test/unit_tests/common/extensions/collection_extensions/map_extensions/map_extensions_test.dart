import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapExtensionNullable Tests', () {
    Map<String, dynamic>? nullableMap;

    setUp(() {
      nullableMap = null;
    });
    group('isNullOrEmpty Group', () {
      test('isNullOrEmpty should return true for null map', () {
        expect(nullableMap.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty should return true for empty map', () {
        nullableMap = {};
        expect(nullableMap.isNullOrEmpty, isTrue);
      });

      test('isNullOrEmpty should return false for non-empty map', () {
        nullableMap = {'key': 1};
        expect(nullableMap.isNullOrEmpty, isFalse);

        nullableMap = {'key': 'test'};
        expect(nullableMap.isNullOrEmpty, isFalse);

        nullableMap = {
          'key': ['test', 'test'],
        };
        expect(nullableMap.isNullOrEmpty, isFalse);

        nullableMap = {'key': null};
        expect(nullableMap.isNullOrEmpty, isFalse);
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
        nullableMap = {'key': 1};
        expect(nullableMap.isNotNullAndNotEmpty, isTrue);

        nullableMap = {'key': 'test'};
        expect(nullableMap.isNotNullAndNotEmpty, isTrue);

        nullableMap = {
          'key': ['test', 'test'],
        };
        expect(nullableMap.isNotNullAndNotEmpty, isTrue);

        nullableMap = {'key': null};
        expect(nullableMap.isNotNullAndNotEmpty, isTrue);
      });
    });
    group('notContainsKey Group', () {
      test('notContainsKey should return true for null map', () {
        expect(nullableMap.notContainsKey('key'), isTrue);
      });

      test('notContainsKey should return true for key not in map', () {
        nullableMap = {'key': 1};
        expect(nullableMap.notContainsKey('anotherKey'), isTrue);
      });

      test('notContainsKey should return false for key in map', () {
        nullableMap = {'key': 1};
        expect(nullableMap.notContainsKey('key'), isFalse);
      });

      test('notContainsKey should return true for null key', () {
        nullableMap = {'key': 1};
        expect(nullableMap.notContainsKey(null), isTrue);
      });
      test('notContainsKey should return true for map with null values for a missing key', () {
        nullableMap = {'key': null};
        expect(nullableMap.notContainsKey('missingKey'), isTrue);
      });
    });
    group('notContainsValue Group', () {
      test('notContainsValue should return true for null map', () {
        expect(nullableMap.notContainsValue(1), isTrue);
      });

      test('notContainsValue should return true for value not in map', () {
        nullableMap = {'key': 1};
        expect(nullableMap.notContainsValue(2), isTrue);

        nullableMap = {'key': 'test'};
        expect(nullableMap.notContainsValue('test2'), isTrue);

        nullableMap = {
          'key': ['test', 'test'],
        };
        expect(nullableMap.notContainsValue(['test']), isTrue);
      });

      test('notContainsValue should return false for value in map', () {
        nullableMap = {'key': 1};
        expect(nullableMap.notContainsValue(1), isFalse);

        nullableMap = {'key': 'test'};
        expect(nullableMap.notContainsValue('test'), isFalse);
      });
    });
  });
}
