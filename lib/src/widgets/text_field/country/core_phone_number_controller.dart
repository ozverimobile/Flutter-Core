import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_core/src/utils/input_formatter/input_formatter.dart';
import 'package:flutter_core/src/widgets/text_field/country/core_country.dart';
import 'package:flutter_core/src/widgets/text_field/country/core_phone_number.dart';

/// [TextEditingController] yerine kullanılabilen, ülke bilgisini de taşıyan controller.
///
/// `CorePhoneNumberTextField.withCountryPicker` alanına verildiğinde ülke ve numara
/// tek yerden okunabilir/yazılabilir:
///
/// ```dart
/// final controller = CorePhoneNumberController(isoCode: 'TR');
/// ...
/// controller.text;             // 555 111 22 33  (maskeli ulusal numara)
/// controller.number;           // 5551112233
/// controller.country.isoCode;  // TR
/// controller.completeNumber;   // +905551112233
/// controller.isValid;          // true
///
/// controller.country = CoreCountry.fromIsoCode('DE')!; // maske otomatik güncellenir
/// controller.number = '5551112233';
/// ```
class CorePhoneNumberController extends TextEditingController {
  CorePhoneNumberController({
    CoreCountry? country,
    String? isoCode,
    String? number,
    String Function(CoreCountry country)? maskResolver,
  })  : _country = country ?? CoreCountry.fromIsoCode(isoCode) ?? CoreCountry.fromIsoCode(_fallbackIsoCode) ?? kCoreCountries.first,
        _maskResolver = maskResolver {
    _formatter = CoreInputFormatter(
      mask: mask,
      filter: {'#': RegExp('[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
    if (number != null && number.isNotEmpty) this.number = number;
  }

  static const String _fallbackIsoCode = 'TR';

  late final CoreInputFormatter _formatter;
  CoreCountry _country;
  String Function(CoreCountry country)? _maskResolver;

  /// Alanın kullandığı maske formatlayıcısı.
  TextInputFormatter get inputFormatter => _formatter;

  /// Seçili ülkeye göre uygulanan maske. Örn: `### ### ## ##`
  String get mask => _maskResolver?.call(_country) ?? _country.mask;

  /// Maskeyi ülkeye göre özelleştirmek için kullanılır.
  String Function(CoreCountry country)? get maskResolver => _maskResolver;

  set maskResolver(String Function(CoreCountry country)? value) {
    if (value == _maskResolver) return;
    _maskResolver = value;
    _reformat();
  }

  /// Seçili ülke.
  CoreCountry get country => _country;

  /// Ülkeyi değiştirir; mevcut rakamlar yeni ülkenin maskesine göre biçimlenir.
  set country(CoreCountry value) {
    if (value == _country) return;
    _country = value;
    _reformat();
  }

  /// Sadece rakamlardan oluşan ulusal numara. Örn: `5551112233`
  String get number => _digitsOf(text);

  /// Numarayı maskeleyerek alana yazar.
  set number(String value) {
    final digits = _digitsOf(value);
    if (digits == number) return;
    _setDigits(digits);
  }

  /// Maskelenmiş ulusal numara ([text] ile aynıdır). Örn: `555 111 22 33`
  String get formattedNumber => text;

  /// Ülke kodu ile birlikte tam numara. Örn: `+905551112233`
  ///
  /// Numara boşsa boş metin döner.
  String get completeNumber => phoneNumber.completeNumber;

  /// Ülke kodu ile birlikte maskelenmiş numara. Örn: `+90 555 111 22 33`
  String get formattedCompleteNumber => phoneNumber.formattedCompleteNumber;

  /// Numaranın ülkenin maskesini tamamen doldurup doldurmadığı.
  bool get isValid => phoneNumber.isValid;

  /// Ülke ve numarayı birlikte taşıyan değer.
  CorePhoneNumber get phoneNumber => CorePhoneNumber(country: _country, number: number, formattedNumber: text);

  /// Ülke ve numarayı birlikte günceller.
  set phoneNumber(CorePhoneNumber value) {
    _country = value.country;
    _setDigits(_digitsOf(value.number));
  }

  /// Sadece numarayı temizler, seçili ülkeyi korur.
  void clearNumber() => _setDigits('');

  @override
  void clear() {
    _formatter.clear();
    super.clear();
  }

  /// Rakamları güncel maskeye göre alana yazar.
  void _setDigits(String digits) {
    final previousText = text;
    value = _formatter.updateMask(
      mask: mask,
      newValue: TextEditingValue(text: digits, selection: TextSelection.collapsed(offset: digits.length)),
    );
    // Metin değişmediyse `value` dinleyicileri tetiklemez; ülke değişimi de duyurulmalı.
    if (text == previousText) notifyListeners();
  }

  /// Maskeyi yeniden uygular (ülke ya da maske değiştiğinde).
  void _reformat() => _setDigits(number);

  String _digitsOf(String value) => value.replaceAll(RegExp('[^0-9]'), '');
}
