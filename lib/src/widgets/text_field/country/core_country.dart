import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_core/src/utils/platform_channel/platform_channel.dart';

part 'core_country_data.dart';
part 'core_country_localizations.dart';

/// Telefon numarası alanında kullanılan ülke modeli.
///
/// Bayraklar asset olarak tutulmaz; [flagEmoji] ISO kodundan
/// (regional indicator karakterleri ile) runtime'da üretilir.
@immutable
class CoreCountry {
  const CoreCountry({
    required this.isoCode,
    required this.dialCode,
    required this.name,
    required this.nameTr,
    required this.mask,
  });

  /// ISO 3166-1 alpha-2 kodu. Örn: `TR`
  final String isoCode;

  /// Başında `+` olmayan ülke kodu. Örn: `90`
  final String dialCode;

  /// Ülkenin İngilizce adı. Örn: `Turkiye`
  final String name;

  /// Ülkenin Türkçe adı. Örn: `Türkiye`
  final String nameTr;

  /// Ulusal numara maskesi. Örn: `### ### ## ##`
  final String mask;

  /// Başında `+` olan ülke kodu. Örn: `+90`
  String get dialCodeWithPlus => '+$dialCode';

  /// Maskenin kabul ettiği toplam rakam adedi. Örn: `TR` için `10`
  int get maxLength => '#'.allMatches(mask).length;

  /// ISO kodundan üretilen bayrak emojisi. Örn: `TR` -> 🇹🇷
  String get flagEmoji {
    const base = 0x1F1E6;
    const asciiA = 0x41;
    final code = isoCode.toUpperCase();
    if (code.length != 2) return '';
    return String.fromCharCodes(
      code.codeUnits.map((unit) => base + (unit - asciiA)),
    );
  }

  /// Verilen [locale] için gösterilecek ülke adı.
  ///
  /// Çözümleme [CoreCountryLocalizations] üzerinden yapılır: önce o dil için
  /// kaydedilmiş ad, yoksa `tr` için [nameTr], diğer tüm durumlarda [name].
  String displayName([Locale? locale]) => CoreCountryLocalizations.resolve(this, locale);

  /// Arama kutusundaki [query] ile eşleşip eşleşmediğini döner.
  ///
  /// Ülke adı (Türkçe + İngilizce + [locale] için kayıtlı ad), ISO kodu ve
  /// ülke kodu üzerinden arar.
  bool matches(String query, {Locale? locale}) {
    final normalizedQuery = normalizeForSearch(query);
    if (normalizedQuery.isEmpty) return true;
    final digitsOnlyQuery = normalizedQuery.replaceAll(RegExp('[^0-9]'), '');
    if (digitsOnlyQuery.isNotEmpty && dialCode.startsWith(digitsOnlyQuery)) return true;
    if (normalizeForSearch(name).contains(normalizedQuery) || normalizeForSearch(nameTr).contains(normalizedQuery) || normalizeForSearch(isoCode).contains(normalizedQuery)) return true;
    final localizedName = locale == null ? null : displayName(locale);
    return localizedName != null && normalizeForSearch(localizedName).contains(normalizedQuery);
  }

  /// Arama ve sıralama için metni sadeleştirir (küçük harf + aksan/Türkçe karakter sadeleştirme).
  static String normalizeForSearch(String value) {
    var result = value.toLowerCase();
    const replacements = <String, String>{
      'ı': 'i',
      'İ': 'i',
      'ş': 's',
      'ğ': 'g',
      'ü': 'u',
      'ö': 'o',
      'ç': 'c',
      'â': 'a',
      'î': 'i',
      'û': 'u',
      'é': 'e',
      'á': 'a',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ã': 'a',
      'õ': 'o',
      'ê': 'e',
      'ô': 'o',
    };
    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result.trim();
  }

  /// ISO koduna göre ülke döner, bulunamazsa `null`.
  static CoreCountry? fromIsoCode(String? isoCode, {List<CoreCountry> countries = kCoreCountries}) {
    if (isoCode == null || isoCode.isEmpty) return null;
    final normalized = isoCode.toUpperCase();
    for (final country in countries) {
      if (country.isoCode == normalized) return country;
    }
    return null;
  }

  /// Ülke koduna göre ülke döner, bulunamazsa `null`.
  ///
  /// `+1` gibi birden fazla ülkenin paylaştığı kodlarda listedeki ilk ülke döner.
  static CoreCountry? fromDialCode(String? dialCode, {List<CoreCountry> countries = kCoreCountries}) {
    if (dialCode == null || dialCode.isEmpty) return null;
    final normalized = dialCode.replaceAll(RegExp('[^0-9]'), '');
    if (normalized.isEmpty) return null;
    for (final country in countries) {
      if (country.dialCode == normalized) return country;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is CoreCountry && other.isoCode == isoCode && other.dialCode == dialCode;

  @override
  int get hashCode => Object.hash(isoCode, dialCode);

  @override
  String toString() => 'CoreCountry($isoCode, $dialCodeWithPlus, $name)';
}
