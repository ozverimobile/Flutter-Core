import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@internal
abstract class CorePlatformChannel {
  static const _channel = MethodChannel('flutter_core');

  static Future<bool> isHuaweiApiAvailable() async {
    return (await _channel.invokeMethod('getHuaweiApiAvailability')) == 0;
  }
}
