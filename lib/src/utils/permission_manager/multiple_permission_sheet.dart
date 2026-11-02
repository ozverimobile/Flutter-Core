import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/utils/permission_manager/permission_page_parts.dart';
import 'package:permission_handler/permission_handler.dart';

enum _SheetPhase { initial, requesting, completed }

enum _ItemStatus {
  idle,
  requesting,
  granted,
  denied,
  permanentlyDenied;

  static _ItemStatus fromPermissionStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted || PermissionStatus.limited || PermissionStatus.provisional => _ItemStatus.granted,
      PermissionStatus.permanentlyDenied || PermissionStatus.restricted => _ItemStatus.permanentlyDenied,
      PermissionStatus.denied => _ItemStatus.denied,
    };
  }

  CorePermissionStatus toCorePermissionStatus() {
    return switch (this) {
      _ItemStatus.granted => CorePermissionStatus.granted,
      _ItemStatus.permanentlyDenied => CorePermissionStatus.permanentlyDenied,
      _ItemStatus.idle || _ItemStatus.requesting || _ItemStatus.denied => CorePermissionStatus.neverPrompted,
    };
  }
}

@immutable
final class MultiplePermissionSheet extends StatefulWidget {
  const MultiplePermissionSheet({
    required this.popupManager,
    required this.id,
    required this.permissions,
    required this.showCloseButton,
    required this.forcedPermissions,
    required this.texts,
    this.title,
    this.titleHighlight,
    this.message,
    this.eyebrow,
    this.eyebrowLeading,
    this.icon,
    this.accentColor,
    this.buttonColor,
    this.permissionLabels,
    this.permissionDescriptions,
    this.requestButtonLabel,
    this.continueButtonLabel,
    this.settingsButtonLabel,
    this.retryButtonLabel,
    this.forcedLabel,
    super.key,
  });

  final PopupManager popupManager;
  final String id;
  final List<CorePermission> permissions;
  final bool showCloseButton;
  final Set<CorePermission> forcedPermissions;
  final CoreMultiplePermissionTexts texts;
  final String? title;
  final String? titleHighlight;
  final String? message;
  final String? eyebrow;
  final Widget? eyebrowLeading;
  final Widget? icon;
  final Color? accentColor;
  final Color? buttonColor;
  final Map<CorePermission, String>? permissionLabels;
  final Map<CorePermission, String>? permissionDescriptions;
  final String? requestButtonLabel;
  final String? continueButtonLabel;
  final String? settingsButtonLabel;
  final String? retryButtonLabel;
  final String? forcedLabel;

  @override
  State<MultiplePermissionSheet> createState() => _MultiplePermissionSheetState();
}

final class _MultiplePermissionSheetState extends State<MultiplePermissionSheet> {
  static const _requestInterval = Duration(milliseconds: 300);

  /// Lets the user see the green checks before the sheet closes itself.
  static const _autoCloseDelay = Duration(milliseconds: 600);

  late final AppLifecycleListener _appLifecycleListener;
  late final Map<CorePermission, _ItemStatus> _statuses = {for (final p in widget.permissions) p: _ItemStatus.idle};

  _SheetPhase _phase = _SheetPhase.initial;

  /// The popup must be hidden only once: auto close, continue and close button can race.
  var _isClosed = false;

  bool get _isAllGranted => _statuses.values.every((s) => s == _ItemStatus.granted);
  bool get _isForcedGranted => widget.forcedPermissions.every((p) => _statuses[p] == _ItemStatus.granted);
  bool get _hasMixedForce => widget.forcedPermissions.isNotEmpty && widget.forcedPermissions.length < widget.permissions.length;
  bool get _isSingle => widget.permissions.length == 1;
  bool get _hasForcedMissing => _phase == _SheetPhase.completed && !_isForcedGranted;
  bool get _hasPermanentlyDenied => _statuses.values.any((s) => s == _ItemStatus.permanentlyDenied);

  Map<CorePermission, CorePermissionStatus> get _result => _statuses.map((p, s) => MapEntry(p, s.toCorePermissionStatus()));

  @override
  void initState() {
    _appLifecycleListener = AppLifecycleListener(onResume: _onResume);
    unawaited(_init());
    super.initState();
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    for (final permission in widget.permissions) {
      final status = await (await permission.permission()).status;
      if (status.isGranted || status.isLimited || status.isProvisional) _statuses[permission] = _ItemStatus.granted;
    }
    if (mounted) setState(() {});
  }

  Future<void> _requestAll() async {
    setState(() => _phase = _SheetPhase.requesting);

    for (final permission in widget.permissions) {
      if (_statuses[permission] == _ItemStatus.granted) continue;
      if (!mounted) return;
      setState(() => _statuses[permission] = _ItemStatus.requesting);

      final status = await (await permission.permission()).request();
      if (!mounted) return;
      setState(() => _statuses[permission] = _ItemStatus.fromPermissionStatus(status));
      await Future<void>.delayed(_requestInterval);
    }

    if (!mounted) return;
    setState(() => _phase = _SheetPhase.completed);
    await _closeIfAllGranted();
  }

  Future<void> _openSettings() => openAppSettings();

  /// Refreshes the statuses whenever the app comes back to the foreground, e.g. from the app
  /// settings (via the settings button or not).
  Future<void> _onResume() async {
    // System permission dialogs also resume the app; [_requestAll] updates the statuses itself.
    if (_phase == _SheetPhase.requesting) return;
    for (final permission in widget.permissions) {
      final status = _ItemStatus.fromPermissionStatus(await (await permission.permission()).status);
      // Before the first request, rows that were never asked stay idle; only grants are shown.
      if (_phase == _SheetPhase.completed || status == _ItemStatus.granted) _statuses[permission] = status;
    }
    if (!mounted) return;
    setState(() {});
    await _closeIfAllGranted();
  }

  /// Closes the sheet as if continue was pressed once every listed permission is granted.
  ///
  /// Granting only the forced permissions keeps the sheet open, so the optional ones can still be granted.
  Future<void> _closeIfAllGranted() async {
    if (!_isAllGranted) return;
    await Future<void>.delayed(_autoCloseDelay);
    if (mounted && _isAllGranted) _close();
  }

  void _close() {
    if (_isClosed) return;
    _isClosed = true;
    widget.popupManager.hidePopup<Map<CorePermission, CorePermissionStatus>>(id: widget.id, result: _result);
  }

  /// Close button: no result, so the caller can tell "closed" apart from "continued".
  void _dismiss() {
    if (_isClosed) return;
    _isClosed = true;
    widget.popupManager.hidePopup<Map<CorePermission, CorePermissionStatus>>(id: widget.id);
  }

  static const _animationDuration = Duration(milliseconds: 250);

  PermissionPalette get _palette => PermissionPalette.of(context, accent: widget.accentColor, button: widget.buttonColor);
  Color get _accent => _palette.accent;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: PermissionPage(
        closeButton: widget.showCloseButton ? PermissionCloseButton(onPressed: _phase == _SheetPhase.requesting ? null : _dismiss) : null,
        body: [
          _buildEyebrow(context),
          _buildHeading(context),
          if (widget.message != null) ...[verticalBox12, CoreText.bodyMedium(widget.message, textColor: context.colorScheme.onSurfaceVariant)],
          const CoreSizedBox(height: 18),
          for (final permission in widget.permissions) _buildPermissionItem(context, permission),
          _buildNote(context),
        ],
        bottom: [_buildSecondaryButton(context), _buildPrimaryButton(context)],
      ),
    );
  }

  /// Small caption above the title, e.g. the logo and name of the feature asking for the permissions.
  Widget _buildEyebrow(BuildContext context) {
    final leading = widget.eyebrowLeading ?? widget.icon;
    if (widget.eyebrow == null && leading == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (leading != null)
            SizedBox.square(
              dimension: 22,
              child: ClipRRect(borderRadius: BorderRadius.circular(6), child: leading),
            ),
          if (leading != null && widget.eyebrow != null) horizontalBox8,
          if (widget.eyebrow != null)
            Flexible(
              child: CoreText.labelMedium(widget.eyebrow, textColor: _accent, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }

  /// Two line title, the second line in the accent color.
  ///
  /// Defaults apply only when neither line is given: a caller passing just [MultiplePermissionSheet.title]
  /// gets a single line, as before.
  (String?, String?) get _headingLines {
    if (_phase == _SheetPhase.completed && !_isAllGranted) {
      final texts = widget.texts;
      if (texts.incompleteTitle != null || texts.incompleteTitleHighlight != null) {
        return (texts.incompleteTitle, texts.incompleteTitleHighlight);
      }
      final missing = _statuses.values.where((s) => s != _ItemStatus.granted).length;
      return (missing == 1 ? 'Bir izin' : '$missing izin', 'eksik kaldı.');
    }
    if (widget.title != null || widget.titleHighlight != null) return (widget.title, widget.titleHighlight);
    return ('Başlamadan önce', 'birkaç izin.');
  }

  Widget _buildHeading(BuildContext context) {
    final (line, highlight) = _headingLines;
    return PermissionHeading(line: line, highlight: highlight, accent: _accent);
  }

  Widget _buildPermissionItem(BuildContext context, CorePermission permission) {
    final status = _statuses[permission]!;
    final isForced = widget.forcedPermissions.contains(permission);
    final (caption, captionColor) = _caption(context, permission, status, isForced: isForced);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        // A lone title sits in the middle of the icon, a title with a caption starts at its top.
        crossAxisAlignment: caption == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          _buildTile(context, permission, status),
          const CoreSizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CoreText.titleMedium(widget.permissionLabels?[permission] ?? _defaultLabel(permission), textColor: context.colorScheme.onSurface, fontWeight: FontWeight.w600),
                    ),
                    if (_hasMixedForce && isForced) ...[horizontalBox8, PermissionBadge(label: widget.forcedLabel ?? 'Zorunlu', color: _accent, radius: 5)],
                  ],
                ),
                if (caption != null) ...[const CoreSizedBox(height: 2), CoreText.bodyMedium(caption, textColor: captionColor)],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Text under the row title: the description until the permission is answered, then the answer.
  (String?, Color) _caption(BuildContext context, CorePermission permission, _ItemStatus status, {required bool isForced}) {
    final texts = widget.texts;
    final deniedColor = isForced ? context.colorScheme.error : context.colorScheme.onSurfaceVariant;
    return switch (status) {
      _ItemStatus.idle || _ItemStatus.requesting => (widget.permissionDescriptions?[permission], context.colorScheme.onSurfaceVariant),
      _ItemStatus.granted => (texts.grantedLabel ?? 'İzin verildi', _palette.success),
      _ItemStatus.denied => (texts.deniedLabel ?? 'Reddedildi', deniedColor),
      _ItemStatus.permanentlyDenied => (texts.permanentlyDeniedLabel ?? "Reddedildi · Ayarlar'dan açabilirsiniz", deniedColor),
    };
  }

  Widget _buildTile(BuildContext context, CorePermission permission, _ItemStatus status) {
    final palette = _palette;
    final error = palette.error;
    final success = palette.success;
    final (Color background, Widget child) = switch (status) {
      _ItemStatus.idle => (_accent, Icon(permission.iconData, size: 24, color: palette.onAccent)),
      _ItemStatus.requesting => (_accent.withValues(alpha: 0.16), SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: _accent))),
      _ItemStatus.granted => (success.withValues(alpha: 0.16), Icon(Icons.check_rounded, size: 24, color: success)),
      _ItemStatus.denied || _ItemStatus.permanentlyDenied => (error.withValues(alpha: 0.12), Icon(Icons.close_rounded, size: 24, color: error)),
    };

    return AnimatedContainer(
      duration: _animationDuration,
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(13)),
      child: AnimatedSwitcher(
        duration: _animationDuration,
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: KeyedSubtree(key: ValueKey(status), child: child),
      ),
    );
  }

  /// Badge and explanation under the list: why the permissions are optional or required.
  Widget _buildNote(BuildContext context) {
    final texts = widget.texts;
    final (String label, String note, Color color) = switch (this) {
      _ when _hasForcedMissing => (
        texts.missingLabel ?? 'Gerekli',
        texts.missingNote ?? "Zorunlu izinler verilmeden devam edilemez. Ayarlar'dan izin verip döndüğünüzde liste kendiliğinden güncellenir.",
        context.colorScheme.error,
      ),
      _ when widget.forcedPermissions.isNotEmpty => (
        widget.forcedLabel ?? 'Zorunlu',
        texts.forcedNote ??
            (_hasMixedForce
                ? 'İşaretli izinler verilmeden devam edilemez. Diğerleri isteğe bağlıdır.'
                : (_isSingle ? 'Bu izin verilmeden devam edilemez.' : 'Bu izinler verilmeden devam edilemez.')),
        _accent,
      ),
      _ => (
        texts.optionalLabel ?? 'İsteğe bağlı',
        texts.optionalNote ?? "${_isSingle ? 'Bu izni' : 'Bu izinleri'} vermeseniz de devam edebilirsiniz. İstediğiniz zaman Ayarlar'dan değiştirebilirsiniz.",
        _palette.info,
      ),
    };
    return PermissionNote(label: label, note: note, color: color);
  }

  Widget _buildSecondaryButton(BuildContext context) {
    final isVisible = _phase == _SheetPhase.completed && !_isAllGranted;
    return AnimatedSize(
      duration: _animationDuration,
      child: !isVisible
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: CoreTextButton(
                  onPressed: _hasPermanentlyDenied ? _openSettings : _requestAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hasPermanentlyDenied) ...[Icon(Icons.settings_rounded, size: 18, color: _accent), const CoreSizedBox(width: 6)],
                      CoreText.titleSmall(
                        _hasPermanentlyDenied ? (widget.settingsButtonLabel ?? 'Ayarlara Git') : (widget.retryButtonLabel ?? 'Tekrar Dene'),
                        textColor: _accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final isInitial = _phase == _SheetPhase.initial;
    final onPressed = switch (_phase) {
      _SheetPhase.initial => _requestAll,
      _SheetPhase.requesting => null,
      _SheetPhase.completed => _isForcedGranted ? _close : null,
    };

    return PermissionPrimaryButton(
      label: isInitial ? (widget.requestButtonLabel ?? 'İzin Ver') : (widget.continueButtonLabel ?? 'Devam Et'),
      onPressed: onPressed,
      palette: _palette,
    );
  }

  /// Short row title; [CorePermission.title] reads as a dialog title ("Kamera İzni") next to the icon.
  static String _defaultLabel(CorePermission permission) {
    return switch (permission) {
      CorePermission.notification => 'Bildirimler',
      CorePermission.camera => 'Kamera',
      CorePermission.photos => 'Fotoğraflar',
      CorePermission.microphone => 'Mikrofon',
      CorePermission.speech => 'Konuşma Tanıma',
      CorePermission.contact => 'Rehber',
      CorePermission.location => 'Konum',
      CorePermission.bluetoothScan => 'Bluetooth Tarama',
      CorePermission.bluetoothConnect => 'Bluetooth Bağlantısı',
    };
  }
}
