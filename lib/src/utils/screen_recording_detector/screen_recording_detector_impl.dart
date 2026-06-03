import 'dart:io';

import 'package:flutter/services.dart';

/// iOS tarafında ekran kaydı (screen recording / mirroring) durumunu dinlemeyi
/// sağlayan yardımcı sınıf.
///
/// Android'de ekran kaydını engellemek için `AndroidScreenshotBlocker.setEnabled`
/// kullanılır; bu sınıf yalnızca **iOS** için anlamlıdır. iOS dışındaki
/// platformlarda [onChanged] boş bir stream, [isRecording] ise `false` döner.
///
/// Kapsanan senaryolar (hepsi native tarafta ele alınır):
/// 1. Uygulama açıkken ekran kaydı başlatıldığında.
/// 2. Ekran kaydı aktifken uygulama açıldığında / dinleme başlatıldığında.
/// 3. Uygulama arka plandayken kayıt başlatılıp uygulama tekrar öne alındığında.
///
/// Kullanım:
/// ```dart
/// final sub = ScreenRecordingDetector.onChanged.listen((isRecording) {
///   if (isRecording) {
///     // İçeriği gizle / dialog göster.
///   }
/// });
/// // İzlemeyi durdurmak için:
/// await sub.cancel();
/// ```
abstract final class ScreenRecordingDetector {
  static const _eventChannel = EventChannel('flutter_core/screen_recording_events');
  static const _methodChannel = MethodChannel('flutter_core/screen_recording');

  static Stream<bool>? _onChanged;

  /// Ekran kaydı durumu her değiştiğinde `true` (kayıt aktif) / `false` (kayıt
  /// kapalı) yayınlar.
  ///
  /// Stream'i dinlemeye başlamak native izlemeyi **açar** (manuel "aç"),
  /// aboneliği iptal etmek native izlemeyi **kapatır** (manuel "kapat").
  /// Dinleme başladığı anda mevcut durum da hemen yayınlanır.
  static Stream<bool> get onChanged {
    if (!Platform.isIOS) return const Stream<bool>.empty();
    return _onChanged ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event == true)
        .distinct();
  }

  /// O anki ekran kaydı durumunu tek seferlik sorgular.
  ///
  /// iOS dışındaki platformlarda her zaman `false` döner.
  static Future<bool> isRecording() async {
    if (!Platform.isIOS) return false;
    final result = await _methodChannel.invokeMethod<bool>('isRecording');
    return result ?? false;
  }
}
