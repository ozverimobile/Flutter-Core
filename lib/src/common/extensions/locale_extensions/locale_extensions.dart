import 'dart:ui';

/// [Locale] EXTENSION
extension LocaleExtension on Locale {
  /// Changes the country code of the locale
  Locale changeCountryCode(String countryCode) => Locale(languageCode, countryCode);
}
