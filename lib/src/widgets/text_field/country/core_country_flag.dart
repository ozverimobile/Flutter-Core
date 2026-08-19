import 'package:flutter/foundation.dart';
import 'package:flutter_core/src/widgets/text_field/country/core_country.dart';
import 'package:material_ui/material_ui.dart';

/// Bayrağın çizim şekli.
enum CoreCountryFlagShape {
  /// Daire. Bayrak daireyi tamamen doldurur, kenarlarından bir miktar kırpılır.
  circle,

  /// Köşeleri yuvarlatılmış dikdörtgen. Bayrağın tamamı görünür, kırpılma olmaz.
  rounded,
}

/// Ülke bayrağını asset kullanmadan çizen widget.
///
/// Bayrak, ISO kodundan üretilen emoji ile render edilir. Emoji bayrak
/// desteklemeyen platformlarda (Windows/Linux) ISO kodu gösterilir.
@immutable
class CoreCountryFlag extends StatelessWidget {
  const CoreCountryFlag({
    required this.country,
    this.size = 28,
    this.shape = CoreCountryFlagShape.circle,
    this.borderColor,
    super.key,
  });

  /// Bayrağı gösterilecek ülke.
  final CoreCountry country;

  /// Bayrağın yüksekliği. [CoreCountryFlagShape.circle] için çapıdır.
  final double size;

  /// Bayrağın çizim şekli.
  final CoreCountryFlagShape shape;

  /// Bayrağın etrafındaki ince çerçeve rengi. `null` ise tema rengi kullanılır.
  final Color? borderColor;

  /// Emoji bayrak karakterinin kendi içinde boşluğu vardır; daireyi tamamen
  /// doldurabilmesi için bir miktar büyütülüp taşan kısmı kırpılır.
  static const double _circleArtworkScale = 1.9;

  /// Emoji bayrak görselinin yaklaşık en/boy oranı.
  static const double _flagAspectRatio = 4 / 3;

  /// Emoji karakterinin görsel yüksekliği kendi punto değerinin altında kaldığı
  /// için bayrağın verilen [size] kadar görünmesi adına uygulanan katsayı.
  static const double _roundedArtworkScale = 1.4;

  /// Emoji bayrakların render edilebildiği platformlar.
  static bool get supportsFlagEmoji {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS || TargetPlatform.android || TargetPlatform.fuchsia => true,
      TargetPlatform.windows || TargetPlatform.linux => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!supportsFlagEmoji) return _FallbackFlag(country: country, size: size, shape: shape);
    return switch (shape) {
      CoreCountryFlagShape.circle => _CircleFlag(
        country: country,
        size: size,
        borderColor: borderColor ?? Theme.of(context).colorScheme.outlineVariant,
      ),
      CoreCountryFlagShape.rounded => _RoundedFlag(country: country, size: size),
    };
  }
}

/// Daireye kırpılmış bayrak.
class _CircleFlag extends StatelessWidget {
  const _CircleFlag({required this.country, required this.size, required this.borderColor});

  final CoreCountry country;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: SizedBox.square(
          dimension: size * CoreCountryFlag._circleArtworkScale,
          child: FittedBox(
            fit: BoxFit.cover,
            child: _FlagText(country: country, fontSize: size),
          ),
        ),
      ),
    );
  }
}

/// Kırpılmadan, kendi köşe yuvarlaklığıyla çizilen bayrak.
class _RoundedFlag extends StatelessWidget {
  const _RoundedFlag({required this.country, required this.size});

  final CoreCountry country;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * CoreCountryFlag._flagAspectRatio,
      height: size,
      child: Center(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: _FlagText(
            country: country,
            fontSize: size * CoreCountryFlag._roundedArtworkScale,
          ),
        ),
      ),
    );
  }
}

class _FlagText extends StatelessWidget {
  const _FlagText({required this.country, required this.fontSize});

  final CoreCountry country;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      country.flagEmoji,
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: fontSize, height: 1),
    );
  }
}

/// Emoji bayrak desteklenmeyen platformlar için ISO kodlu görünüm.
class _FallbackFlag extends StatelessWidget {
  const _FallbackFlag({required this.country, required this.size, required this.shape});

  final CoreCountry country;
  final double size;
  final CoreCountryFlagShape shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCircle = shape == CoreCountryFlagShape.circle;
    return Container(
      width: isCircle ? size : size * CoreCountryFlag._flagAspectRatio,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(size * 0.22),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Text(
        country.isoCode,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: size * 0.36,
          height: 1,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
