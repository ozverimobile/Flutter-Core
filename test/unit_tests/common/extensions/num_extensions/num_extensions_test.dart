import 'package:flutter_core/src/common/extensions/num_extensions/num_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('To Localized Price', () {
    test('Test to localized price', () {
      const price = 1000.0;
      final localizedPrice = price.toLocalizedPrice();
      expect(localizedPrice, '1.000,00');
    });

    test('Test to localized price with decimal', () {
      const price = 1000.0;
      final localizedPrice = price.toLocalizedPrice(decimal: 3);
      expect(localizedPrice, '1.000,000');
    });

    test('Test to localized price with null', () {
      const num? price = null;
      final localizedPrice = price?.toLocalizedPrice();
      expect(localizedPrice, null);
    });

    test('Test zero to localized price', () {
      const price = 0.0;
      final localizedPrice = price.toLocalizedPrice();
      expect(localizedPrice, '0,00');
    });

    test('Test to big localized price', () {
      const price = 1000000.0;
      final localizedPrice = price.toLocalizedPrice();
      expect(localizedPrice, '1.000.000,00');
    });
  });
}
