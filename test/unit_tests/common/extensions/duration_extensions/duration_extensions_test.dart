import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationExtension Tests', () {
    test('delay() should execute callback after duration', () async {
      const duration = Duration(seconds: 1);
      final stopwatch = Stopwatch()..start();

      await duration.delay(() {
        expect(stopwatch.elapsed.inSeconds, greaterThanOrEqualTo(1));
      });

      stopwatch.stop();
    });

    test('delay() should return null when no callback is provided', () async {
      const duration = Duration(seconds: 1);
      final result = await duration.delay<Duration?>();
      expect(result, isNull);
    });

    test('tommss should return mm:ss format', () {
      const duration = Duration(minutes: 1, seconds: 30);
      expect(duration.tommss, '01:30');

      const zeroDuration = Duration(seconds: 6);
      expect(zeroDuration.tommss, '00:06');

      const hourDuration = Duration(hours: 1, minutes: 1, seconds: 30);
      expect(hourDuration.tommss, '01:30');
    });

    test('toHHmmss should return HH:mm:ss format', () {
      const duration = Duration(hours: 1, minutes: 30, seconds: 15);
      expect(duration.toHHmmss, '01:30:15');

      const onlyMinutesDuration = Duration(minutes: 45);
      expect(onlyMinutesDuration.toHHmmss, '00:45:00');

      const durationWithDays = Duration(days: 1, hours: 2, minutes: 30, seconds: 4);
      expect(durationWithDays.toHHmmss, '02:30:04');
    });

    test('toHHmmss should handle zero duration correctly', () {
      const zeroDuration = Duration.zero;
      expect(zeroDuration.toHHmmss, '00:00:00');
    });

    test('tommss should handle zero duration correctly', () {
      const zeroDuration = Duration.zero;
      expect(zeroDuration.tommss, '00:00');
    });
  });
}
