import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/src/utils/device_integrity/device_integrity_models.dart';

/// Android'de root, iOS'ta jailbreak tespiti; ek olarak hook (Frida, Xposed/LSPosed,
/// Substrate...), emülatör/simülatör, debugger ve Android'de bootloader / geliştirici
/// ayarları kontrolü.
///
/// Kontroller native tarafta, arka plan thread'inde, birbirinden bağımsız birçok
/// yöntemle yapılır. Sonuç bulguların listesidir; nasıl tepki verileceğine
/// uygulama karar verir.
///
/// İstemci tarafı tespit tek başına kesin değildir: yeterince uğraşan bir saldırgan
/// her kontrolü atlatabilir. Kritik işlemler (ödeme, giriş) için sunucu tarafında
/// Play Integrity / App Attest doğrulamasıyla birlikte kullanılmalıdır.
///
/// Kullanım:
/// ```dart
/// final result = await CoreDeviceIntegrity.check();
/// if (result.isCompromised) {
///   // Uyarı göster / hassas özellikleri kapat / sunucuya raporla.
///   log(result.findings.toString());
/// }
/// ```
abstract final class CoreDeviceIntegrity {
  static const _channel = MethodChannel('flutter_core/device_integrity');

  @visibleForTesting
  static bool? debugIsSupported;

  /// Yalnızca Android ve iOS desteklenir; diğer platformlarda [check] boş sonuç döner.
  static bool get isSupported =>
      debugIsSupported ??
      (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS));

  /// Tüm kontrolleri çalıştırır. Her çağrıda yeniden kontrol edilir (Frida gibi
  /// araçlar uygulama açıkken bağlanabilir). Native tarafta arka plan thread'inde çalışır
  /// ama Android'de birkaç process çağrısı yaptığı için 1 saniyeye yaklaşabilir; açılışta
  /// ve kritik işlemlerden önce çağrılması yeterlidir, sık döngülerde çağrılmamalıdır.
  ///
  /// Hata fırlatmaz: native taraf hata verirse [CoreDeviceIntegrityResult.isCheckFailed] true olur.
  static Future<CoreDeviceIntegrityResult> check() async {
    if (!isSupported) return CoreDeviceIntegrityResult.empty;
    try {
      final raw = await _channel.invokeListMethod<Object?>('check');
      final findings = (raw ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(CoreIntegrityFinding.fromMap)
          .toList(growable: false);
      return CoreDeviceIntegrityResult(findings: findings);
    } on Object catch (error) {
      return CoreDeviceIntegrityResult.failed(error);
    }
  }

  /// Cihaz root/jailbreak'li veya uygulamaya hook enjekte edilmişse `true`.
  ///
  /// [failClosed] true ise kontrol çalıştırılamadığında da `true` döner.
  static Future<bool> isCompromised({bool failClosed = false}) async {
    final result = await check();
    return result.isCompromised || (failClosed && result.isCheckFailed);
  }
}
