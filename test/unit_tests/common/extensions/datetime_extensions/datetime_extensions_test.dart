import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await initializeDateFormatting();
  group('DateTimeExtension Tests', () {
    final testDate = DateTime(2024, 4, 3, 12); // 3 Nisan 2024 Çarşamba

    test('toDayName returns correct day name', () {
      expect(testDate.toDayName(locale: 'tr'), 'Çarşamba');
      expect(testDate.toDayName(locale: 'en'), 'Wednesday');
    });

    test('toMonthName returns correct month name', () {
      expect(testDate.toMonthName(locale: 'tr'), 'Nisan');
      expect(testDate.toMonthName(locale: 'en'), 'April');
    });

    test('toTimeAgoString returns correct time ago string', () {
      final now = DateTime.now();
      expect(now.subtract(const Duration(seconds: 10)).toTimeAgoString, 'Şimdi');
      expect(now.subtract(const Duration(seconds: 45)).toTimeAgoString, '45 saniye önce');
      expect(now.subtract(const Duration(minutes: 3)).toTimeAgoString, '3 dakika önce');
      expect(now.subtract(const Duration(hours: 5)).toTimeAgoString, '5 saat önce');
      expect(now.subtract(const Duration(days: 2)).toTimeAgoString, '2 gün önce');
    });

    test('todMMMMEEEE formats date correctly', () {
      expect(testDate.todMMMMEEEE(locale: 'tr'), '3 Nisan Çarşamba');
      expect(testDate.todMMMMEEEE(locale: 'en'), '3 April Wednesday');
    });

    test('todMMMMMy formats date correctly', () {
      expect(testDate.todMMMMMy(locale: 'tr'), '3 Nisan 2024');
      expect(testDate.todMMMMMy(locale: 'en'), '3 April 2024');
    });

    test('toMMMMy formats date correctly', () {
      expect(testDate.toMMMMy(locale: 'tr'), 'Nisan 2024');
      expect(testDate.toMMMMy(locale: 'en'), 'April 2024');
    });

    test('todMMMM formats date correctly', () {
      expect(testDate.todMMMM(locale: 'tr'), '3 Nisan');
      expect(testDate.todMMMM(locale: 'en'), '3 April');
    });

    test('todMMMMyHHmm formats date correctly', () {
      expect(testDate.todMMMMyHHmm(locale: 'tr'), '3 Nisan 2024 12:00');
      expect(testDate.todMMMMyHHmm(locale: 'en'), '3 April 2024 12:00');
    });

    test('todMMMMHHmm formats date correctly', () {
      expect(testDate.todMMMMHHmm(locale: 'tr'), '3 Nisan 12:00');
      expect(testDate.todMMMMHHmm(locale: 'en'), '3 April 12:00');
    });

    test('toHHmm formats time correctly', () {
      expect(testDate.toHHmm, '12:00');
    });

    test('toddMMyHHmmss formats date correctly', () {
      expect(testDate.toddMMyHHmmss, '03.04.2024 12:00:00');
    });
    test('toddMMyHHmm formats date and time correctly', () {
      expect(testDate.toddMMyHHmm, '03.04.2024 12:00');
    });

    test('toddMMy formats date correctly', () {
      expect(testDate.toddMMy, '03.04.2024');
    });

    test('toyMMdd formats date correctly', () {
      expect(testDate.toyMMdd, '2024.04.03');
    });

    test('toyyyyMMdd formats date correctly', () {
      expect(testDate.toyyyyMMdd, '2024-04-03');
    });

    test('toyyyyMMddHHmmss formats date correctly', () {
      expect(testDate.toyyyyMMddHHmmss, '2024-04-03 12:00:00');
    });
    test('totalDaysInCurrentMonth returns correct total days', () {
      expect(testDate.totalDaysInCurrentMonth, 30);
      expect(DateTime(2024, 2).totalDaysInCurrentMonth, 29);
      expect(DateTime(2023, 2).totalDaysInCurrentMonth, 28);
      expect(DateTime(2024, 5).totalDaysInCurrentMonth, 31);
    });

    test('isSameDate returns true for same day', () {
      final otherDate = DateTime(2024, 4, 3, 18);
      final missingDate = DateTime(2022, 4, 3, 18);
      expect(testDate.isSameDate(otherDate), true);
      expect(testDate.isSameDate(missingDate), false);
    });

    test('isToday returns true for today', () {
      final now = DateTime.now();
      expect(now.isToday, true);
      expect(testDate.isToday, false);
    });

    test('isCurrentMonthAndYear returns true for current month and year', () {
      final now = DateTime.now();
      expect(now.isCurrentMonthAndYear, true);
      expect(testDate.isCurrentMonthAndYear, false);
    });
  });
}
