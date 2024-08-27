import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Enumerations of color codes for ease of use
enum LogColors { black, red, green, yellow, blue, magenta, cyan, white }

/// A UTILITY FOR PRINTING COLORFUL LOGS FOR DEBUG AND PROFILE MODE
abstract class CoreLogger {
  static const _name = 'Core';

  /// Prints colorful log with given message only form Debug and Profile mode
  static void log(Object? msg, {LogColors color = LogColors.green}) {
    if (kDebugMode || kProfileMode) {
      switch (color) {
        case LogColors.black:
          developer.log('\x1B[30m$msg\x1B[0m', name: _name);
        case LogColors.red:
          developer.log('\x1B[31m$msg\x1B[0m', name: _name);
        case LogColors.green:
          developer.log('\x1B[32m$msg\x1B[0m', name: _name);
        case LogColors.yellow:
          developer.log('\x1B[33m$msg\x1B[0m', name: _name);
        case LogColors.blue:
          developer.log('\x1B[34m$msg\x1B[0m', name: _name);
        case LogColors.magenta:
          developer.log('\x1B[35m$msg\x1B[0m', name: _name);
        case LogColors.cyan:
          developer.log('\x1B[36m$msg\x1B[0m', name: _name);
        case LogColors.white:
          developer.log('\x1B[37m$msg\x1B[0m', name: _name);
      }
    }
  }
}
