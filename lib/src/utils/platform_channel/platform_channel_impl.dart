import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@internal
abstract class CorePlatformChannel {
  static const _channel = MethodChannel('flutter_core');

  static Future<bool> isHuaweiApiAvailable() async {
    return (await _channel.invokeMethod('getHuaweiApiAvailability')) == 0;
  }

  static Future<String?> getAndroidDeviceId() async => _channel.invokeMethod('getAndroidId');

  /// Cihazın kendi dil verisinden ülke adlarını döner.
  ///
  /// [languageCode] için işletim sisteminin ICU verisi kullanılır; bu sayede
  /// paket içinde çeviri taşımaya gerek kalmaz. Desteklenmeyen platformlarda
  /// (web/Windows/Linux) boş map döner.
  static Future<Map<String, String>> getLocalizedCountryNames({
    required String languageCode,
    required List<String> isoCodes,
  }) async {
    try {
      final result = await _channel.invokeMapMethod<String, String>(
        'getLocalizedCountryNames',
        <String, Object?>{'languageCode': languageCode, 'isoCodes': isoCodes},
      );
      return result ?? const <String, String>{};
    } on Object {
      return const <String, String>{};
    }
  }
}
