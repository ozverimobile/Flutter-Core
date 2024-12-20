import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntExtension Tests', () {
    test('microseconds should return correct Duration', () {
      expect(100.microseconds, const Duration(microseconds: 100));
    });

    test('milliseconds should return correct Duration', () {
      expect(100.milliseconds, const Duration(milliseconds: 100));
    });

    test('seconds should return correct Duration', () {
      expect(1.seconds, const Duration(seconds: 1));
    });

    test('minutes should return correct Duration', () {
      expect(1.minutes, const Duration(minutes: 1));
    });

    test('hours should return correct Duration', () {
      expect(1.hours, const Duration(hours: 1));
    });

    test('days should return correct Duration', () {
      expect(1.days, const Duration(days: 1));
    });

    test('bytesToKilobytes should return correct conversion', () {
      expect(1024.bytesToKilobytes, 1);
      expect(2048.bytesToKilobytes, 2);
    });

    test('bytesToMegabytes should return correct conversion', () {
      expect(1048576.bytesToMegabytes, 1);
      expect(2097152.bytesToMegabytes, 2);
    });

    test('bytesToGigabytes should return correct conversion', () {
      expect(1073741824.bytesToGigabytes, 1);
      expect(2147483648.bytesToGigabytes, 2);
    });

    test('kiloBytesToBytes should return correct conversion', () {
      expect(1.kiloBytesToBytes, 1024);
      expect(2.kiloBytesToBytes, 2048);
    });

    test('kiloBytesToMegabytes should return correct conversion', () {
      expect(1024.kiloBytesToMegabytes, 1);
      expect(2048.kiloBytesToMegabytes, 2);
    });

    test('kiloBytesToGigabytes should return correct conversion', () {
      expect(1048576.kiloBytesToGigabytes, 1);
      expect(2097152.kiloBytesToGigabytes, 2);
    });

    test('megaBytesToBytes should return correct conversion', () {
      expect(1.megaBytesToBytes, 1048576);
      expect(2.megaBytesToBytes, 2097152);
    });

    test('megaBytesToKilobytes should return correct conversion', () {
      expect(1.megaBytesToKilobytes, 1024);
      expect(2.megaBytesToKilobytes, 2048);
    });

    test('megaBytesToGigabytes should return correct conversion', () {
      expect(1024.megaBytesToGigabytes, 1);
      expect(2048.megaBytesToGigabytes, 2);
    });

    test('gigaBytesToBytes should return correct conversion', () {
      expect(1.gigaBytesToBytes, 1073741824);
      expect(2.gigaBytesToBytes, 2147483648);
    });

    test('gigaBytesToKilobytes should return correct conversion', () {
      expect(1.gigaBytesToKilobytes, 1048576);
      expect(2.gigaBytesToKilobytes, 2097152);
    });

    test('gigaBytesToMegabytes should return correct conversion', () {
      expect(1.gigaBytesToMegabytes, 1024);
      expect(2.gigaBytesToMegabytes, 2048);
    });
  });
}
