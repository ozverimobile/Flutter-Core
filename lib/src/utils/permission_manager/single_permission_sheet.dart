import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/utils/permission_manager/permission_page_parts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page of `CorePermissionManager.requestPermission`: explains one permission, then asks the system for it.
///
/// A permanently denied permission can only be granted from the app settings: the page says so itself
/// and its button opens the settings directly. The status is read again once the app is back.
@immutable
final class SinglePermissionSheet extends StatefulWidget {
  const SinglePermissionSheet({
    required this.popupManager,
    required this.permission,
    required this.id,
    required this.isPermanentDenied,
    required this.showAskLaterOption,
    this.title,
    this.message,
    this.icon,
    super.key,
  });

  final PopupManager popupManager;
  final CorePermission permission;
  final String id;
  final bool isPermanentDenied;
  final bool showAskLaterOption;
  final String? title;
  final String? message;
  final Widget? icon;

  @override
  State<SinglePermissionSheet> createState() => _SinglePermissionSheetState();
}

final class _SinglePermissionSheetState extends State<SinglePermissionSheet> {
  late final AppLifecycleListener _appLifecycleListener;

  /// Completed when the app is back from the settings.
  Completer<void>? _settingsReturn;

  String? _message;

  /// The popup must be hidden only once.
  var _isClosed = false;

  @override
  void initState() {
    _appLifecycleListener = AppLifecycleListener(onResume: _onResume);
    unawaited(_loadMessage());
    super.initState();
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _loadMessage() async {
    final message = widget.message ?? await widget.permission.message();
    if (mounted) setState(() => _message = message);
  }

  void _onResume() {
    final settingsReturn = _settingsReturn;
    if (settingsReturn != null && !settingsReturn.isCompleted) settingsReturn.complete();
  }

  void _hide(CorePermissionStatus status) {
    if (_isClosed) return;
    _isClosed = true;
    widget.popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: status);
  }

  Future<void> _request() async {
    final status = await (await widget.permission.permission()).request();
    _hide(CorePermissionStatus.fromPermissionStatus(status));
  }

  Future<void> _openSettings() async {
    if (_settingsReturn != null) return;
    _settingsReturn = Completer<void>();
    await openAppSettings();
    await _settingsReturn!.future;
    _settingsReturn = null;
    final status = await (await widget.permission.permission()).status;
    _hide(CorePermissionStatus.fromPermissionStatus(status));
  }

  Future<void> _askLater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(widget.permission.sharedPrefKey, _postponeMilliseconds);
    _hide(CorePermissionStatus.postponed);
  }

  @override
  Widget build(BuildContext context) {
    final palette = PermissionPalette.of(context);
    final isDenied = widget.isPermanentDenied;

    return PopScope(
      canPop: false,
      child: PermissionPage(
        closeButton: PermissionCloseButton(onPressed: () => _hide(CorePermissionStatus.neverPrompted)),
        body: [
          _buildTile(palette),
          const CoreSizedBox(height: 24),
          PermissionHeading(
            line: widget.title ?? '${_headingName(widget.permission)} izni',
            // A caller's own title stays a single line.
            highlight: widget.title != null ? null : (isDenied ? 'kapalı.' : 'gerekiyor.'),
            accent: palette.accent,
          ),
          if (_message != null) ...[
            const CoreSizedBox(height: 14),
            CoreText.bodyLarge(_message, textColor: context.colorScheme.onSurfaceVariant),
          ],
          if (isDenied)
            PermissionNote(
              label: 'Ayarlar',
              note: "Bu izin daha önce reddedildi, telefon bir daha sormaz. Ayarlar'dan açıp geri döndüğünüzde kaldığınız yerden devam edersiniz.",
              color: palette.error,
            )
          else
            PermissionNote(
              label: 'Bilgi',
              note: "Devam edince telefonunuz izni soracak. İstediğiniz zaman Ayarlar'dan değiştirebilirsiniz.",
              color: palette.info,
            ),
        ],
        bottom: [
          PermissionPrimaryButton(
            label: isDenied ? 'Ayarlara Git' : 'İzin Ver',
            icon: isDenied ? Icons.settings_rounded : null,
            onPressed: isDenied ? _openSettings : _request,
            palette: palette,
          ),
          if (widget.showAskLaterOption && !isDenied) ...[
            const CoreSizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: CoreTextButton(
                onPressed: _askLater,
                child: CoreText.titleSmall('Sonra Hatırlat', textColor: context.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTile(PermissionPalette palette) {
    final isDenied = widget.isPermanentDenied;
    final foreground = isDenied ? palette.error : palette.onAccent;
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDenied ? palette.error.withValues(alpha: 0.12) : palette.accent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: widget.icon ?? Icon(widget.permission.iconData, size: 34, color: foreground),
    );
  }

  /// First line of the default title, read with "izni": "Kamera izni".
  static String _headingName(CorePermission permission) {
    return switch (permission) {
      CorePermission.notification => 'Bildirim',
      CorePermission.camera => 'Kamera',
      CorePermission.photos => 'Fotoğraf',
      CorePermission.microphone => 'Mikrofon',
      CorePermission.speech => 'Konuşma tanıma',
      CorePermission.contact => 'Rehber',
      CorePermission.location => 'Konum',
      CorePermission.bluetoothScan => 'Bluetooth tarama',
      CorePermission.bluetoothConnect => 'Bluetooth bağlantı',
    };
  }
}

int get _postponeMilliseconds {
  // 7 days
  return DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 24 * 7;
}
