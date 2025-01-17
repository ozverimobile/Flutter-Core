import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class CoreText extends StatelessWidget {
  const CoreText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  })  : textColor = null,
        fontWeight = null,
        _textTheme = null;

  /// Ekrandaki en büyük metindir;
  ///
  /// Büyük ekranlarda en iyi şekilde çalışırlar.
  const CoreText.displayLarge(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.displayLarge;

  /// Ekrandaki en büyük metindir;
  ///
  /// Büyük ekranlarda en iyi şekilde çalışırlar.
  const CoreText.displayMedium(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.displayMedium;

  /// Ekrandaki en büyük metindir;
  ///
  /// Büyük ekranlarda en iyi şekilde çalışırlar.
  const CoreText.displaySmall(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.displaySmall;

  /// Card veya Dialog'daki başlık metinleri için kullanılır.
  const CoreText.headlineLarge(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.headlineLarge;

  /// Card veya Dialog'daki başlık metinleri için kullanılır.
  const CoreText.headlineMedium(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.headlineMedium;

  /// Card veya Dialog'daki başlık metinleri için kullanılır.
  const CoreText.headlineSmall(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.headlineSmall;

  /// AppBar veya ListTile'daki başlık metinleri için kullanılır.
  const CoreText.titleLarge(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.titleLarge;

  /// AppBar veya ListTile'daki başlık metinleri için kullanılır.
  const CoreText.titleMedium(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.titleMedium;

  /// AppBar veya ListTile'daki başlık metinleri için kullanılır.
  const CoreText.titleSmall(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.titleSmall;

  /// Button veya Chip metinleri için kullanılır.
  const CoreText.labelLarge(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.labelLarge;

  /// Button veya Chip metinleri için kullanılır.
  const CoreText.labelMedium(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.labelMedium;

  /// Button veya Chip metinleri için kullanılır.
  const CoreText.labelSmall(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.labelSmall;

  /// Genel Text metinleri için kullanılır.
  const CoreText.bodyLarge(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.bodyLarge;

  /// Genel Text metinleri için kullanılır.
  const CoreText.bodyMedium(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.bodyMedium;

  /// Genel Text metinleri için kullanılır.
  const CoreText.bodySmall(
    this.data, {
    super.key,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textColor,
    this.fontWeight,
  })  : style = null,
        _textTheme = CoreTextTheme.bodySmall;

  final String? data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final Color? textColor;
  final FontWeight? fontWeight;

  final CoreTextTheme? _textTheme;

  @override
  Widget build(BuildContext context) {
    return CoreSemantics(
      id: semanticsLabel ?? 'CoreText',
      child: switch (data) {
        null || '' => emptyBox,
        _ => Text(
            data!,
            style: style ?? _textTheme?.toTextStyle(context)?.copyWith(color: textColor, fontWeight: fontWeight),
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            textScaler: textScaler,
            maxLines: maxLines,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
            selectionColor: selectionColor,
          )
      },
    );
  }
}
