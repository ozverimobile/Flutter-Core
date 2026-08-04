import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Enumerations of color codes for ease of use
enum LogColors { black, red, green, yellow, blue, magenta, cyan, white }

/// A UTILITY FOR PRINTING COLORFUL LOGS FOR DEBUG AND PROFILE MODE
abstract class CoreLogger {
  static const _name = 'Core';

  static const _ansiCodes = <LogColors, int>{
    LogColors.black: 30,
    LogColors.red: 31,
    LogColors.green: 32,
    LogColors.yellow: 33,
    LogColors.blue: 34,
    LogColors.magenta: 35,
    LogColors.cyan: 36,
    LogColors.white: 37,
  };

  /// Prints colorful log with given message only form Debug and Profile mode
  static void log(Object? msg, {LogColors color = LogColors.green}) {
    if (kDebugMode || kProfileMode) {
      final ansiCode = _ansiCodes[color];
      final coloredMsg = '$msg'.split('\n').map((line) => '\x1B[${ansiCode}m$line\x1B[0m').join('\n');
      developer.log(coloredMsg, name: _name);
    }
  }
}
