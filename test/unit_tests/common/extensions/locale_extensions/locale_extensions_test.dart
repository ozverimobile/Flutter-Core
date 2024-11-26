import 'dart:ui';

import 'package:flutter_core/src/common/extensions/locale_extensions/locale_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Change Country Code', () {
    test('Test change country code', () {
      const locale = Locale('en', 'US');
      final result = locale.changeCountryCode('CA');
      expect(result.countryCode, 'CA');
    });

    test('Test change country code to empty', () {
      const locale = Locale('en', 'US');
      final result = locale.changeCountryCode('');
      expect(result.countryCode, '');
    });
  });
}
