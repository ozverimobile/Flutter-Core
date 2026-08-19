import 'dart:async';
import 'dart:io';

import 'package:flutter_core/flutter_core.dart';
import 'package:material_ui/material_ui.dart';

/// Ekran kaydına/görüntüsüne karşı içeriği koruyan platform-bağımsız
/// sarmalayıcı widget.
///
/// Her projede dinleme + dialog/engelleme mantığını tekrar yazmamak için
/// tasarlanmıştır. Uygulamanı bu widget ile sar ve [enabled] ile manuel olarak
/// aç/kapat:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => CoreScreenRecordingGuard(
///     enabled: true, // sadece aç/kapat
///     child: child!,
///   ),
/// );
/// ```
///
/// Platform davranışı:
/// - **Android**: `FLAG_SECURE` etkinleştirilir; bu hem ekran görüntüsünü hem
///   de ekran kaydını sistem seviyesinde engeller. Ekstra bir katman/uyarı
///   gösterilmez (gerek yoktur).
/// - **iOS**: Ekran kaydı/AirPlay/QuickTime yansıtması algılandığında [child]'ın
///   üzerine tam ekran opak bir katman bindirilir; böylece içerik hem gizlenir
///   hem de kullanıcıya uyarı gösterilir. Kayıt durunca katman otomatik kalkar.
/// - Diğer platformlarda [child] olduğu gibi gösterilir.
class CoreScreenRecordingGuard extends StatefulWidget {
  const CoreScreenRecordingGuard({
    required this.child,
    this.enabled = true,
    this.overlayBuilder,
    this.onStateChanged,
    super.key,
  });

  /// Korunacak içerik.
  final Widget child;

  /// İzlemenin açık olup olmadığı. `false` yapıldığında dinleme durur ve varsa
  /// uyarı katmanı kaldırılır.
  final bool enabled;

  /// Kayıt aktifken gösterilecek özel katman. Verilmezse varsayılan uyarı
  /// kartı gösterilir. Yalnızca iOS'ta kullanılır.
  final WidgetBuilder? overlayBuilder;

  /// Ekran kaydı durumu her değiştiğinde tetiklenir (`true` => kayıt aktif).
  /// Yalnızca iOS'ta tetiklenir.
  final ValueChanged<bool>? onStateChanged;

  @override
  State<CoreScreenRecordingGuard> createState() => _CoreScreenRecordingGuardState();
}

class _CoreScreenRecordingGuardState extends State<CoreScreenRecordingGuard> {
  StreamSubscription<bool>? _subscription;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _enableProtection();
  }

  @override
  void didUpdateWidget(covariant CoreScreenRecordingGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled == oldWidget.enabled) return;
    if (widget.enabled) {
      _enableProtection();
    } else {
      _disableProtection();
    }
  }

  @override
  void dispose() {
    // iOS dinlemesini kapat. Android tarafında FLAG_SECURE'u da temizliyoruz ki
    // widget ağaçtan kalkınca koruma takılı kalmasın.
    unawaited(_subscription?.cancel());
    if (Platform.isAndroid) {
      unawaited(AndroidScreenshotBlocker.setEnabled(false));
    }
    super.dispose();
  }

  void _enableProtection() {
    if (Platform.isAndroid) {
      // FLAG_SECURE: hem ekran görüntüsünü hem ekran kaydını engeller.
      unawaited(AndroidScreenshotBlocker.setEnabled(true));
    } else if (Platform.isIOS) {
      _subscription ??= ScreenRecordingDetector.onChanged.listen(_handleStateChange);
    }
  }

  void _disableProtection() {
    if (Platform.isAndroid) {
      unawaited(AndroidScreenshotBlocker.setEnabled(false));
    } else if (Platform.isIOS) {
      unawaited(_subscription?.cancel());
      _subscription = null;
      if (_isRecording) _updateRecording(false);
    }
  }

  void _handleStateChange(bool isRecording) {
    if (!mounted) return;
    _updateRecording(isRecording);
  }

  void _updateRecording(bool isRecording) {
    setState(() => _isRecording = isRecording);
    widget.onStateChanged?.call(isRecording);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isRecording)
          Positioned.fill(
            child: widget.overlayBuilder?.call(context) ?? const _DefaultRecordingOverlay(),
          ),
      ],
    );
  }
}

class _DefaultRecordingOverlay extends StatelessWidget {
  const _DefaultRecordingOverlay();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.screen_share, color: Colors.red, size: 40),
                SizedBox(height: 16),
                Text(
                  'Ekran Kaydı Algılandı',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Güvenlik nedeniyle ekran kaydı yapılırken bu içerik '
                  'görüntülenemez. Lütfen ekran kaydını durdurun.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
