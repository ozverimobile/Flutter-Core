import 'package:flutter/services.dart';

abstract final class AndroidScreenshotBlocker {
  static const _channel = MethodChannel('flutter_core');

  // Fonskiyon adından alacağı parametre belli olduğı için named olmasına gerek yok.
  // ignore: avoid_positional_boolean_parameters
  static Future<void> setEnabled(bool enabled) {
    return _channel.invokeMethod<void>('setSecure', {'enabled': enabled});
  }
}
