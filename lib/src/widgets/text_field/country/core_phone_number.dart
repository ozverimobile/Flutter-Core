import 'package:flutter/foundation.dart';
import 'package:flutter_core/src/widgets/text_field/country/core_country.dart';

/// Ülke seçimli telefon alanının ürettiği değer.
@immutable
class CorePhoneNumber {
  const CorePhoneNumber({
    required this.country,
    required this.number,
    required this.formattedNumber,
  });

  /// Seçili ülke.
  final CoreCountry country;

  /// Sadece rakamlardan oluşan ulusal numara. Örn: `5551112233`
  final String number;

  /// Maskelenmiş hali. Örn: `555 111 22 33`
  final String formattedNumber;

  /// Ülke kodu ile birlikte tam numara. Örn: `+905551112233`
  ///
  /// Numara boşsa boş metin döner.
  String get completeNumber => isEmpty ? '' : '${country.dialCodeWithPlus}$number';

  /// Ülke kodu ile birlikte maskelenmiş numara. Örn: `+90 555 111 22 33`
  ///
  /// Numara boşsa boş metin döner.
  String get formattedCompleteNumber => isEmpty ? '' : '${country.dialCodeWithPlus} $formattedNumber';

  /// Numaranın boş olup olmadığı.
  bool get isEmpty => number.isEmpty;

  /// Numaranın ülkenin maskesini tamamen doldurup doldurmadığı.
  bool get isValid => number.length == country.maxLength;

  CorePhoneNumber copyWith({CoreCountry? country, String? number, String? formattedNumber}) {
    return CorePhoneNumber(
      country: country ?? this.country,
      number: number ?? this.number,
      formattedNumber: formattedNumber ?? this.formattedNumber,
    );
  }

  @override
  bool operator ==(Object other) => other is CorePhoneNumber && other.country == country && other.number == number;

  @override
  int get hashCode => Object.hash(country, number);

  @override
  String toString() => 'CorePhoneNumber($completeNumber)';
}
