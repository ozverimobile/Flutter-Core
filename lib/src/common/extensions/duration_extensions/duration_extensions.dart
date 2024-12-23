import 'dart:async';

/// [Duration] EXTENSIONS
extension DurationExtension on Duration {
  /// Converts duration object to Future with an optional callback
  Future<T?> delay<T>([FutureOr<T> Function()? callback]) async => Future<T>.delayed(this, callback);

  /// Formats the duration as mm:ss eg. 01:30
  String get tommss {
    final minutes =inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Formats the duration as HH:mm:ss eg. 01:30:15
  String get toHHmmss {
    final hours = inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
