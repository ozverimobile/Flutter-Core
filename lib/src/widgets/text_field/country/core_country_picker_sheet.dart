import 'dart:async';

import 'package:flutter_core/src/widgets/text_field/country/core_country.dart';
import 'package:flutter_core/src/widgets/text_field/country/core_country_flag.dart';
import 'package:material_ui/material_ui.dart';

/// Ülke seçim sayfasının görünüm ve metin ayarları.
@immutable
class CoreCountryPickerOptions {
  const CoreCountryPickerOptions({
    this.title = 'Ülke Seçin',
    this.searchHintText = 'Ülke arayın...',
    this.emptyResultText = 'Sonuç bulunamadı',
    this.countries,
    this.favoriteIsoCodes = const <String>[],
    this.showDialCode = true,
    this.flagShape = CoreCountryFlagShape.circle,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
    this.barrierColor,
    this.backgroundColor,
    this.useRootNavigator = false,
    this.isDismissible = true,
    this.enableDrag = true,
    this.nameResolver,
    this.itemBuilder,
  });

  /// Sayfa başlığı.
  final String title;

  /// Arama alanının hint metni.
  final String searchHintText;

  /// Arama sonucu boş olduğunda gösterilecek metin.
  final String emptyResultText;

  /// Listelenecek ülkeler. `null` ise [kCoreCountries] kullanılır.
  final List<CoreCountry>? countries;

  /// Listenin en üstünde sabitlenecek ülkelerin ISO kodları. Örn: `['TR', 'US']`
  final List<String> favoriteIsoCodes;

  /// Satırın sağında ülke kodunun (`+90`) gösterilip gösterilmeyeceği.
  final bool showDialCode;

  /// Listedeki bayrakların çizim şekli.
  final CoreCountryFlagShape flagShape;

  /// Başlığın solunda kapatma butonunun gösterilip gösterilmeyeceği.
  final bool showCloseButton;

  /// Sayfanın üstünde tutamaç gösterilip gösterilmeyeceği.
  final bool showDragHandle;

  /// Sayfanın köşe yarıçapı.
  final BorderRadiusGeometry borderRadius;

  /// Arka plan karartma rengi.
  final Color? barrierColor;

  /// Sayfanın arka plan rengi. `null` ise tema rengi kullanılır.
  final Color? backgroundColor;

  /// Root navigator üzerinden açılıp açılmayacağı.
  final bool useRootNavigator;

  /// Boşluğa dokununca kapanıp kapanmayacağı.
  final bool isDismissible;

  /// Sürükleyerek kapatmaya izin verilip verilmeyeceği.
  final bool enableDrag;

  /// Ülke adını özelleştirmek için kullanılır. `null` ise locale'e göre
  /// [CoreCountry.displayName] kullanılır.
  final String Function(BuildContext context, CoreCountry country)? nameResolver;

  /// Liste satırını tamamen özelleştirmek için kullanılır.
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(BuildContext context, CoreCountry country, bool isSelected, VoidCallback onTap)? itemBuilder;
}

/// Tam sayfa açılan, aranabilir ülke seçim bottom sheet'i.
///
/// Doğrudan da kullanılabilir:
/// ```dart
/// final country = await CoreCountryPickerSheet.show(context, selected: myCountry);
/// ```
@immutable
class CoreCountryPickerSheet extends StatefulWidget {
  const CoreCountryPickerSheet({
    required this.onSelected,
    this.selected,
    this.options = const CoreCountryPickerOptions(),
    super.key,
  });

  /// Seçili ülke.
  final CoreCountry? selected;

  /// Görünüm ayarları.
  final CoreCountryPickerOptions options;

  /// Bir ülke seçildiğinde tetiklenir.
  final ValueChanged<CoreCountry> onSelected;

  /// Ülke seçim sayfasını açar ve seçilen ülkeyi döner.
  ///
  /// Kullanıcı seçim yapmadan kapatırsa `null` döner.
  static Future<CoreCountry?> show(
    BuildContext context, {
    CoreCountry? selected,
    CoreCountryPickerOptions options = const CoreCountryPickerOptions(),
  }) {
    return showModalBottomSheet<CoreCountry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: options.isDismissible,
      enableDrag: options.enableDrag,
      barrierColor: options.barrierColor,
      backgroundColor: Colors.transparent,
      useRootNavigator: options.useRootNavigator,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: SizedBox(
            height: double.infinity,
            child: CoreCountryPickerSheet(
              selected: selected,
              options: options,
              onSelected: (country) => Navigator.of(sheetContext).pop(country),
            ),
          ),
        );
      },
    );
  }

  @override
  State<CoreCountryPickerSheet> createState() => _CoreCountryPickerSheetState();
}

class _CoreCountryPickerSheetState extends State<CoreCountryPickerSheet> {
  static const double _itemHeight = 56;

  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;
  late final List<CoreCountry> _source;
  late final List<CoreCountry> _favorites;
  late List<CoreCountry> _orderedCountries;
  late List<CoreCountry> _visibleCountries;
  Locale? _locale;
  bool _isScrollScheduled = false;

  @override
  void initState() {
    super.initState();
    _favorites = _buildFavorites();
    _source = _buildCountryList();
    _orderedCountries = _source;
    _visibleCountries = _source;
    _scrollController = ScrollController();
    CoreCountryLocalizations.revision.addListener(_onCountryNamesChanged);
    _scrollToSelected();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.maybeLocaleOf(context);
    if (locale == _locale) return;
    _locale = locale;
    // Cihazın dil verisinden ülke adlarını yükler; hazır olduğunda liste yenilenir.
    unawaited(CoreCountryLocalizations.load(locale, countries: _source));
    _reorder();
  }

  @override
  void dispose() {
    CoreCountryLocalizations.revision.removeListener(_onCountryNamesChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Favori ülkeler, verildikleri sırayla listenin başında tutulur.
  List<CoreCountry> _buildFavorites() {
    final source = widget.options.countries ?? kCoreCountries;
    final favorites = <CoreCountry>[];
    for (final isoCode in widget.options.favoriteIsoCodes) {
      final country = CoreCountry.fromIsoCode(isoCode, countries: source);
      if (country != null && !favorites.contains(country)) favorites.add(country);
    }
    return List<CoreCountry>.unmodifiable(favorites);
  }

  List<CoreCountry> _buildCountryList() {
    final source = widget.options.countries ?? kCoreCountries;
    if (_favorites.isEmpty) return List<CoreCountry>.unmodifiable(source);
    final others = source.where((country) => !_favorites.contains(country));
    return List<CoreCountry>.unmodifiable([..._favorites, ...others]);
  }

  /// Ülke adları değiştiğinde (dil yüklendi ya da elle kayıt yapıldı) listeyi yeniler.
  void _onCountryNamesChanged() {
    if (mounted) _reorder();
  }

  /// Listeyi gösterilen ada göre sıralar; favoriler en üstte kalır.
  void _reorder() {
    final others = _source.where((country) => !_favorites.contains(country)).toList()..sort((a, b) => CoreCountry.normalizeForSearch(_nameOf(a)).compareTo(CoreCountry.normalizeForSearch(_nameOf(b))));
    setState(() {
      _orderedCountries = <CoreCountry>[..._favorites, ...others];
      _visibleCountries = _filter(_searchController.text);
    });
    _scrollToSelected();
  }

  /// Seçili ülkeyi görünür kılmak için gereken scroll değeri.
  double _offsetOfSelected() {
    final index = _orderedCountries.indexOf(widget.selected!);
    if (index <= 2) return 0;
    return (index - 2) * _itemHeight;
  }

  /// Seçili ülkeyi listede görünür yapar.
  ///
  /// Liste henüz yerleşmediyse (ilk açılış ya da sıralama değişimi) bir sonraki
  /// kareye ertelenir.
  void _scrollToSelected() {
    if (widget.selected == null || _searchController.text.isNotEmpty || _visibleCountries.isEmpty) return;
    if (!_scrollController.hasClients) {
      if (_isScrollScheduled) return;
      _isScrollScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isScrollScheduled = false;
        if (mounted) _scrollToSelected();
      });
      return;
    }
    final maxOffset = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(_offsetOfSelected().clamp(0, maxOffset < 0 ? 0 : maxOffset));
  }

  List<CoreCountry> _filter(String query) {
    if (query.trim().isEmpty) return _orderedCountries;
    return _orderedCountries.where((country) => country.matches(query, locale: _locale)).toList();
  }

  void _onSearchChanged(String query) => setState(() => _visibleCountries = _filter(query));

  String _nameOf(CoreCountry country) {
    final resolver = widget.options.nameResolver;
    if (resolver != null) return resolver(context, country);
    return country.displayName(_locale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: widget.options.backgroundColor ?? theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: widget.options.borderRadius),
      child: Column(
        children: [
          if (widget.options.showDragHandle) const _DragHandle(),
          _Header(
            title: widget.options.title,
            showCloseButton: widget.options.showCloseButton,
          ),
          _SearchField(
            controller: _searchController,
            hintText: widget.options.searchHintText,
            onChanged: _onSearchChanged,
          ),
          Expanded(
            child: _visibleCountries.isEmpty
                ? _EmptyResult(text: widget.options.emptyResultText)
                : ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 12),
                    itemExtent: _itemHeight,
                    itemCount: _visibleCountries.length,
                    itemBuilder: (context, index) {
                      final country = _visibleCountries[index];
                      final isSelected = country == widget.selected;
                      void onTap() => widget.onSelected(country);
                      final itemBuilder = widget.options.itemBuilder;
                      if (itemBuilder != null) return itemBuilder(context, country, isSelected, onTap);
                      return _CountryTile(
                        country: country,
                        name: _nameOf(country),
                        isSelected: isSelected,
                        showDialCode: widget.options.showDialCode,
                        flagShape: widget.options.flagShape,
                        onTap: onTap,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handleSize = theme.bottomSheetTheme.dragHandleSize ?? const Size(32, 4);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: handleSize.width,
        height: handleSize.height,
        decoration: BoxDecoration(
          color: theme.bottomSheetTheme.dragHandleColor ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(handleSize.height / 2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.showCloseButton});

  final String title;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      // Başlık ve geri butonu sayfanın soluna hizalanır.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showCloseButton)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: Navigator.of(context).maybePop,
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, showCloseButton ? 0 : 12, 20, 12),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700) ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hintText, required this.onChanged});

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.name,
    required this.isSelected,
    required this.showDialCode,
    required this.flagShape,
    required this.onTap,
  });

  final CoreCountry country;
  final String name;
  final bool isSelected;
  final bool showDialCode;
  final CoreCountryFlagShape flagShape;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(14);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? colorScheme.primary.withValues(alpha: 0.06) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: isSelected ? BorderSide(color: colorScheme.primary, width: 1.2) : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                CoreCountryFlag(country: country, shape: flagShape),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (showDialCode) ...[
                  const SizedBox(width: 8),
                  Text(
                    country.dialCodeWithPlus,
                    // Ülke kodu RTL dillerde de `+90` şeklinde okunmalı.
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
