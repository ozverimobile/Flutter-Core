part of 'core_country.dart';

/// Ülke adlarının uygulamanın diline göre çözümlenmesini sağlar.
///
/// Adlar **cihazın kendi dil verisinden** (ICU) alınır; bu sayede paket içinde
/// ya da projede çeviri taşımaya gerek kalmaz. Kullanıcı uygulama içinden dili
/// değiştirdiğinde `Localizations.localeOf(context)` değiştiği için adlar
/// kendiliğinden yeni dile geçer.
///
/// Çözümleme sırası:
/// 1. `CoreCountryPickerOptions.nameResolver` (ekrana özel, en öncelikli)
/// 2. [register] ile elle kaydedilmiş adlar
/// 3. Cihazdan gelen yerelleştirilmiş ad
/// 4. Paket içindeki `tr` / `en` adları
///
/// Cihazdan ad okuma iOS, macOS ve Android'de çalışır; diğer platformlarda
/// 4. adıma düşülür. [useSystemNames] ile tamamen kapatılabilir.
abstract final class CoreCountryLocalizations {
  static final Map<String, Map<String, String>> _registry = <String, Map<String, String>>{};
  static final Map<String, Map<String, String>> _systemNames = <String, Map<String, String>>{};
  static final Set<String> _loadingLanguageCodes = <String>{};
  static final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  /// Cihazdan yerelleştirilmiş ülke adı okunup okunmayacağı.
  static bool useSystemNames = true;

  /// Yeni adlar yüklendiğinde artar; ülke adı gösteren widget'lar bunu dinler.
  static ValueListenable<int> get revision => _revision;

  /// Elle kayıt yapılmış dillerin kodları.
  static Iterable<String> get registeredLanguageCodes => _registry.keys;

  /// [languageCode] dili için ülke adlarını elle kaydeder.
  ///
  /// Cihazdan gelen adların önüne geçer. [names] anahtarları ISO 3166-1 alpha-2
  /// ülke kodudur. Yalnızca birkaç ülkeyi düzeltmek için de kullanılabilir:
  ///
  /// ```dart
  /// CoreCountryLocalizations.register('tr', {'MK': 'Kuzey Makedonya'});
  /// ```
  static void register(String languageCode, Map<String, String> names) {
    final key = _normalizeLanguageCode(languageCode);
    final target = _registry.putIfAbsent(key, () => <String, String>{});
    names.forEach((isoCode, name) => target[isoCode.toUpperCase()] = name);
    _bumpRevision();
  }

  /// [languageCode] için elle kaydedilmiş adları siler. Verilmezse tümü silinir.
  static void unregister([String? languageCode]) {
    if (languageCode == null) {
      _registry.clear();
    } else {
      _registry.remove(_normalizeLanguageCode(languageCode));
    }
    _bumpRevision();
  }

  /// Cihazdan alınan adları önbellekten siler (test amaçlı).
  @visibleForTesting
  static void clearSystemNames() {
    _systemNames.clear();
    _loadingLanguageCodes.clear();
    _bumpRevision();
  }

  /// [locale] dili için ülke adlarını cihazdan yükler.
  ///
  /// Aynı dil için birden fazla çağrılması güvenlidir; sonuç önbelleğe alınır.
  /// Yükleme bitince [revision] artar ve dinleyen widget'lar yeniden çizilir.
  static Future<void> load(Locale? locale, {List<CoreCountry> countries = kCoreCountries}) async {
    if (!useSystemNames || locale == null) return;
    final languageCode = _normalizeLanguageCode(locale.languageCode);
    if (languageCode.isEmpty) return;
    if (_systemNames.containsKey(languageCode) || _loadingLanguageCodes.contains(languageCode)) return;

    _loadingLanguageCodes.add(languageCode);
    try {
      final names = await CorePlatformChannel.getLocalizedCountryNames(
        languageCode: languageCode,
        isoCodes: countries.map((country) => country.isoCode).toList(),
      );
      // Boş sonuç da önbelleğe alınır; desteklenmeyen platformda tekrar denenmesin.
      _systemNames[languageCode] = names;
    } finally {
      _loadingLanguageCodes.remove(languageCode);
    }
    _bumpRevision();
  }

  /// [country] ülkesinin [locale] diline göre adını döner.
  static String resolve(CoreCountry country, Locale? locale) {
    final languageCode = locale == null ? null : _normalizeLanguageCode(locale.languageCode);
    if (languageCode != null && languageCode.isNotEmpty) {
      final registered = _registry[languageCode]?[country.isoCode];
      if (registered != null && registered.isNotEmpty) return registered;

      final systemName = _systemNames[languageCode]?[country.isoCode];
      if (systemName != null && systemName.isNotEmpty) return systemName;

      if (languageCode == 'tr') return country.nameTr;
    }
    return country.name;
  }

  static String _normalizeLanguageCode(String languageCode) => languageCode.toLowerCase().trim();

  static void _bumpRevision() => _revision.value++;
}
