import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/src/utils/input_formatter/input_formatter.dart';
import 'package:flutter_core/src/widgets/text_field/country/country.dart';

const String _trCountryCode = '90';
const String _trCarrierPrefix = '5';
const String _defaultPickerIsoCode = 'TR';

enum PhoneNumberFormat {
  /// 555 555 55 55
  plain,

  /// (555) 555 55 55
  withParens,

  /// +90 (555) 555 55 55
  withCountryParens,

  /// +90 (555) 555 55 55 with prefix +90 (5
  prefixWithCountryParens,

  /// +90 555 555 55 55
  withCountry,

  /// +90 555 555 55 55 with prefix +90 5
  prefixWithCountry,

  /// 0 (555) 555 55 55
  withZeroParens,

  /// 0 (555) 555 55 55 with prefix 0 (5
  /// ONLY WORK FOR TURKEY COUNTRY CODE
  prefixWithZeroParens,

  /// 0 555 555 55 55
  withZero,

  /// 0 555 555 55 55 with prefix 0
  /// ONLY WORK FOR TURKEY COUNTRY CODE
  prefixWithZero;

  String get mask {
    return switch (this) {
      PhoneNumberFormat.plain => '### ### ## ##',
      PhoneNumberFormat.withParens => '(###) ### ## ##',
      PhoneNumberFormat.withCountryParens => '+## (###) ### ## ##',
      PhoneNumberFormat.withCountry => '+## ### ### ## ##',
      PhoneNumberFormat.withZeroParens => '0 (###) ### ## ##',
      PhoneNumberFormat.withZero => '0 ### ### ## ##',
      PhoneNumberFormat.prefixWithCountryParens => '##) ### ## ##',
      PhoneNumberFormat.prefixWithCountry => '## ### ## ##',
      PhoneNumberFormat.prefixWithZeroParens => '##) ### ## ##',
      PhoneNumberFormat.prefixWithZero => '(###) ### ## ##',
    };
  }

  String? _prefix(String countryCode, String carrierPrefix) {
    return switch (this) {
      PhoneNumberFormat.prefixWithCountryParens => '+$countryCode ($carrierPrefix',
      PhoneNumberFormat.prefixWithCountry => '+$countryCode $carrierPrefix',
      PhoneNumberFormat.prefixWithZeroParens when countryCode == _trCountryCode => '0 ($carrierPrefix',
      PhoneNumberFormat.prefixWithZero when countryCode == _trCountryCode => '0 $carrierPrefix',
      _ => null,
    };
  }
}

@immutable
class CorePhoneNumberTextField extends StatelessWidget {
  const CorePhoneNumberTextField({
    this.controller,
    this.validator,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.autovalidateMode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.textInputAction,
    this.prefixIcon,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.buildCounter,
    this.enabled,
    this.focusNode,
    this.autofillHints,
    this.format = PhoneNumberFormat.withCountryParens,
    this.countryCode = _trCountryCode,
    this.carrierPrefix = _trCarrierPrefix,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.enableInteractiveSelection = false,
    super.key,
  })  : hasCountryPicker = false,
        initialCountry = null,
        initialCountryIsoCode = null,
        onCountryChanged = null,
        onPhoneNumberChanged = null,
        phoneNumberValidator = null,
        countryPickerOptions = const CoreCountryPickerOptions(),
        showSelectedFlag = true,
        showSelectedDialCode = true,
        maskResolver = null;

  /// Solunda ülke seçimi olan telefon alanı.
  ///
  /// Ülke butonuna basıldığında tam sayfa, aranabilir bir bottom sheet açılır.
  /// Seçilen ülkeye göre maske otomatik güncellenir; alandaki metin **sadece
  /// ulusal numarayı** tutar, ülke kodu solda ayrı gösterilir.
  ///
  /// ```dart
  /// CorePhoneNumberTextField.withCountryPicker(
  ///   hintText: 'Telefon',
  ///   initialCountryIsoCode: 'TR',
  ///   onPhoneNumberChanged: (phone) => print(phone.completeNumber), // +905551112233
  /// )
  /// ```
  const CorePhoneNumberTextField.withCountryPicker({
    this.controller,
    this.validator,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.autovalidateMode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.textInputAction,
    this.prefixIcon,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.buildCounter,
    this.enabled,
    this.focusNode,
    this.autofillHints,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.enableInteractiveSelection = false,
    this.initialCountry,
    this.initialCountryIsoCode,
    this.onCountryChanged,
    this.onPhoneNumberChanged,
    this.phoneNumberValidator,
    this.countryPickerOptions = const CoreCountryPickerOptions(),
    this.showSelectedFlag = true,
    this.showSelectedDialCode = true,
    this.maskResolver,
    super.key,
  })  : hasCountryPicker = true,
        format = PhoneNumberFormat.plain,
        countryCode = _trCountryCode,
        carrierPrefix = _trCarrierPrefix;

  /// Alanın controller'ı.
  ///
  /// [CorePhoneNumberTextField.withCountryPicker] ile birlikte bir
  /// [CorePhoneNumberController] verilirse ülke ve numara tek yerden
  /// okunabilir (`controller.country`, `controller.completeNumber`).
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final String? hintText;
  final String? labelText;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final bool? enabled;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final PhoneNumberFormat format;
  final String countryCode;
  final String carrierPrefix;
  final FloatingLabelBehavior floatingLabelBehavior;
  final bool enableInteractiveSelection;

  /// Ülke seçimli kullanım (`CorePhoneNumberTextField.withCountryPicker`) olup olmadığı.
  final bool hasCountryPicker;

  /// Başlangıçta seçili olacak ülke. Verilirse [initialCountryIsoCode] yok sayılır.
  final CoreCountry? initialCountry;

  /// Başlangıçta seçili olacak ülkenin ISO kodu. Örn: `TR`
  ///
  /// `null` ise; [controller] bir [CorePhoneNumberController] ise onun ülkesi,
  /// değilse `TR` kullanılır.
  final String? initialCountryIsoCode;

  /// Ülke değiştiğinde tetiklenir.
  final void Function(CoreCountry country)? onCountryChanged;

  /// Numara ya da ülke değiştiğinde tetiklenir.
  final void Function(CorePhoneNumber phoneNumber)? onPhoneNumberChanged;

  /// Ülke bilgisiyle birlikte doğrulama yapmak için kullanılır.
  ///
  /// [validator] ile birlikte kullanılabilir; önce [validator] çalışır.
  final String? Function(CorePhoneNumber phoneNumber)? phoneNumberValidator;

  /// Ülke seçim sayfasının ayarları.
  final CoreCountryPickerOptions countryPickerOptions;

  /// Alanın solunda bayrağın gösterilip gösterilmeyeceği.
  ///
  /// Bayrağın şekli [CoreCountryPickerOptions.flagShape] ile belirlenir.
  final bool showSelectedFlag;

  /// Alanın solunda ülke kodunun (`+90`) gösterilip gösterilmeyeceği.
  final bool showSelectedDialCode;

  /// Ülkeye göre maskeyi özelleştirmek için kullanılır.
  /// `null` ise [CoreCountry.mask] kullanılır.
  final String Function(CoreCountry country)? maskResolver;

  @override
  Widget build(BuildContext context) {
    if (hasCountryPicker) return _CountryPickerPhoneNumberTextField(field: this);
    return TextFormField(
      enableInteractiveSelection: enableInteractiveSelection,
      controller: controller,
      enabled: enabled,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      textAlign: textAlign,
      autovalidateMode: autovalidateMode,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      keyboardType: TextInputType.phone,
      maxLength: maxLength,
      buildCounter: buildCounter,
      autofillHints: autofillHints,
      inputFormatters: [
        CoreDefaultInputFormatter.phoneNumberByType(format),
      ],
      decoration: InputDecoration(
        floatingLabelBehavior: floatingLabelBehavior,
        prefixText: format._prefix(countryCode, carrierPrefix),
        prefixIcon: prefixIcon,
        hintText: hintText,
        labelText: labelText,
      ),
    );
  }
}

/// [CorePhoneNumberTextField.withCountryPicker] için ülke durumunu tutan alan.
class _CountryPickerPhoneNumberTextField extends StatefulWidget {
  const _CountryPickerPhoneNumberTextField({required this.field});

  final CorePhoneNumberTextField field;

  @override
  State<_CountryPickerPhoneNumberTextField> createState() => _CountryPickerPhoneNumberTextFieldState();
}

class _CountryPickerPhoneNumberTextFieldState extends State<_CountryPickerPhoneNumberTextField> {
  /// Ülke bilgisini taşıyan controller. Dışarıdan [CorePhoneNumberController]
  /// verilmediyse içeride oluşturulur.
  CorePhoneNumberController? _phoneController;
  bool _ownsPhoneController = false;

  /// Dışarıdan düz bir [TextEditingController] verildiğinde kullanılır.
  TextEditingController? _plainController;
  late CoreCountry _localCountry;
  late final CoreInputFormatter _localFormatter;

  FocusNode? _internalFocusNode;
  late CoreCountry _lastCountry;

  List<CoreCountry> get _countries => widget.field.countryPickerOptions.countries ?? kCoreCountries;

  TextEditingController get _controller => _phoneController ?? _plainController!;

  FocusNode get _focusNode => widget.field.focusNode ?? (_internalFocusNode ??= FocusNode());

  CoreCountry get _country => _phoneController?.country ?? _localCountry;

  TextInputFormatter get _formatter => _phoneController?.inputFormatter ?? _localFormatter;

  String get _mask => _phoneController?.mask ?? widget.field.maskResolver?.call(_country) ?? _country.mask;

  CorePhoneNumber get _phoneNumber {
    return _phoneController?.phoneNumber ??
        CorePhoneNumber(
          country: _country,
          number: _digitsOf(_controller.text),
          formattedNumber: _controller.text,
        );
  }

  @override
  void initState() {
    super.initState();
    final givenController = widget.field.controller;
    final explicitCountry = _explicitCountry();
    if (givenController is CorePhoneNumberController) {
      _phoneController = givenController;
      if (widget.field.maskResolver != null && givenController.maskResolver == null) {
        givenController.maskResolver = widget.field.maskResolver;
      }
      if (explicitCountry != null) givenController.country = explicitCountry;
    } else if (givenController == null) {
      _ownsPhoneController = true;
      _phoneController = CorePhoneNumberController(
        country: explicitCountry ?? _defaultCountry,
        maskResolver: widget.field.maskResolver,
      );
    } else {
      _plainController = givenController;
      _localCountry = explicitCountry ?? _defaultCountry;
      _localFormatter = CoreInputFormatter(
        mask: _mask,
        filter: {'#': RegExp('[0-9]')},
        type: MaskAutoCompletionType.eager,
      );
      _applyLocalMask();
    }
    _phoneController?.addListener(_onPhoneControllerChanged);
    _lastCountry = _country;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ülke adları cihazın dil verisinden okunur; seçim sayfası açılmadan hazırlanır.
    unawaited(CoreCountryLocalizations.load(Localizations.maybeLocaleOf(context), countries: _countries));
  }

  @override
  void didUpdateWidget(covariant _CountryPickerPhoneNumberTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isoCodeChanged = oldWidget.field.initialCountryIsoCode != widget.field.initialCountryIsoCode;
    final countryChanged = oldWidget.field.initialCountry != widget.field.initialCountry;
    if (!isoCodeChanged && !countryChanged) return;
    final explicitCountry = _explicitCountry();
    if (explicitCountry == null || explicitCountry == _country) return;
    _selectCountry(explicitCountry, notify: false);
  }

  @override
  void dispose() {
    _phoneController?.removeListener(_onPhoneControllerChanged);
    if (_ownsPhoneController) _phoneController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// Widget üzerinden açıkça belirtilmiş ülke.
  CoreCountry? _explicitCountry() {
    return widget.field.initialCountry ?? CoreCountry.fromIsoCode(widget.field.initialCountryIsoCode, countries: _countries);
  }

  CoreCountry get _defaultCountry => CoreCountry.fromIsoCode(_defaultPickerIsoCode, countries: _countries) ?? _countries.first;

  /// Controller üzerinden ülke değiştiğinde arayüzü günceller.
  void _onPhoneControllerChanged() {
    final country = _phoneController?.country;
    if (country == null || country == _lastCountry) return;
    setState(() => _lastCountry = country);
  }

  /// Düz controller modunda maskeyi yeniden uygular.
  void _applyLocalMask() {
    final controller = _plainController;
    if (controller == null) return;
    final digits = _digitsOf(controller.text);
    final value = _localFormatter.updateMask(
      mask: _mask,
      newValue: TextEditingValue(text: digits, selection: TextSelection.collapsed(offset: digits.length)),
    );
    if (value.text != controller.text) controller.value = value;
  }

  String _digitsOf(String value) => value.replaceAll(RegExp('[^0-9]'), '');

  Future<void> _openCountryPicker() async {
    final hadFocus = _focusNode.hasFocus;
    _focusNode.unfocus();
    final country = await CoreCountryPickerSheet.show(
      context,
      selected: _country,
      options: widget.field.countryPickerOptions,
    );
    if (country == null || !mounted) return;
    _selectCountry(country);
    if (hadFocus) _focusNode.requestFocus();
  }

  void _selectCountry(CoreCountry country, {bool notify = true}) {
    if (country == _country) return;
    final phoneController = _phoneController;
    if (phoneController != null) {
      phoneController.country = country;
    } else {
      setState(() => _localCountry = country);
      _applyLocalMask();
    }
    _lastCountry = country;
    if (!notify) return;
    widget.field.onCountryChanged?.call(country);
    widget.field.onPhoneNumberChanged?.call(_phoneNumber);
  }

  void _onChanged(String value) {
    widget.field.onChanged?.call(value);
    widget.field.onPhoneNumberChanged?.call(_phoneNumber);
  }

  String? _validate(String? value) {
    final result = widget.field.validator?.call(value);
    if (result != null) return result;
    return widget.field.phoneNumberValidator?.call(_phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final hasValidator = widget.field.validator != null || widget.field.phoneNumberValidator != null;
    return TextFormField(
      enableInteractiveSelection: widget.field.enableInteractiveSelection,
      controller: _controller,
      enabled: widget.field.enabled,
      focusNode: _focusNode,
      validator: hasValidator ? _validate : null,
      onChanged: _onChanged,
      textAlign: widget.field.textAlign,
      autovalidateMode: widget.field.autovalidateMode,
      onEditingComplete: widget.field.onEditingComplete,
      onFieldSubmitted: widget.field.onFieldSubmitted,
      textInputAction: widget.field.textInputAction,
      keyboardType: TextInputType.phone,
      maxLength: widget.field.maxLength,
      buildCounter: widget.field.buildCounter,
      autofillHints: widget.field.autofillHints,
      inputFormatters: [_formatter],
      decoration: InputDecoration(
        floatingLabelBehavior: widget.field.floatingLabelBehavior,
        prefixIcon: _CountrySelectorButton(
          country: _country,
          leading: widget.field.prefixIcon,
          showFlag: widget.field.showSelectedFlag,
          flagShape: widget.field.countryPickerOptions.flagShape,
          showDialCode: widget.field.showSelectedDialCode,
          onTap: (widget.field.enabled ?? true) ? _openCountryPicker : null,
        ),
        // Ülke butonunun kendi genişliğinde durabilmesi için minimum sınırlar kaldırılır.
        prefixIconConstraints: const BoxConstraints(),
        hintText: widget.field.hintText,
        labelText: widget.field.labelText,
      ),
    );
  }
}

/// Alanın solunda duran, ülke seçim sayfasını açan buton.
class _CountrySelectorButton extends StatelessWidget {
  const _CountrySelectorButton({
    required this.country,
    required this.leading,
    required this.showFlag,
    required this.flagShape,
    required this.showDialCode,
    required this.onTap,
  });

  final CoreCountry country;
  final Widget? leading;
  final bool showFlag;
  final CoreCountryFlagShape flagShape;
  final bool showDialCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;
    final foregroundColor = isEnabled ? theme.colorScheme.onSurface : theme.disabledColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
              if (showFlag) ...[
                CoreCountryFlag(country: country, size: 24, shape: flagShape),
                const SizedBox(width: 6),
              ],
              if (showDialCode) ...[
                Text(
                  country.dialCodeWithPlus,
                  // Ülke kodu RTL dillerde de `+90` şeklinde okunmalı.
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodyLarge?.copyWith(color: foregroundColor),
                ),
                const SizedBox(width: 2),
              ],
              Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: foregroundColor),
            ],
          ),
        ),
      ),
    );
  }
}
