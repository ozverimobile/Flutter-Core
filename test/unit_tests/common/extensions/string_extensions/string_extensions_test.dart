import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Is Email Test', () {
    test('Handles empty input', () {
      expect(''.isEmail, false);
    });

    test('Handles invalid input', () {
      expect('test@test'.isEmail, false);
    });

    test('Handles valid input', () {
      expect('ozdilek@ozdilek.com.tr'.isEmail, true);
    });
  });

  group('Is Null Or Empty', () {
    test('Handles empty input', () {
      expect(''.isNullOrEmpty, true);
    });

    test('Handles null input', () {
      const String? nullString = null;
      expect(nullString.isNullOrEmpty, true);
    });

    test('Handles non-empty input', () {
      expect('test'.isNullOrEmpty, false);
    });
  });

  group('Is Not Null And Not Empty', () {
    test('Handles empty input', () {
      expect(''.isNotNullAndNotEmpty, false);
    });

    test('Handles null input', () {
      const String? nullString = null;
      expect(nullString.isNotNullAndNotEmpty, false);
    });

    test('Handles non-empty input', () {
      expect('test'.isNotNullAndNotEmpty, true);
    });
  });

  group('To Null If Empty', () {
    test('Handles empty input', () {
      expect(''.toNullIfEmpty, null);
    });

    test('Handles non-empty input', () {
      expect('test'.toNullIfEmpty, 'test');
    });
  });

  group('Truncate to Length', () {
    test('Handles input shorter than length', () {
      expect('test'.truncateToLength(), 'test');
    });

    test('Handles input longer than length', () {
      expect('testtesttesttesttest'.truncateToLength(), 'testtesttesttesttest');
    });

    test('Handles input longer than length with custom length', () {
      expect('testtesttesttesttest'.truncateToLength(length: 5), 'testt...');
    });

    test('Handles input longer than length with custom suffix', () {
      expect('testtesttesttesttest'.truncateToLength(length: 5, suffix: '***'), 'testt***');
    });
  });
}
