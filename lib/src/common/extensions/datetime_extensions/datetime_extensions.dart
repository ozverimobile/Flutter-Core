import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:intl/intl.dart';

/// [DateTime] Extension
extension DateTimeExtension on DateTime {
  /// prints the day name of the date
  String toDayName({String? locale}) {
    return DateFormat('EEEE', locale).format(this);
  }

  /// prints the month name of the date
  String toMonthName({String? locale}) {
    return DateFormat('MMMM', locale).format(this);
  }

  /// Formats string as time ago
  ///
  /// eg. 5 seconds ago, 1 minute ago, 1 hour ago, 1 day ago
  String get toTimeAgoString {
    // TODO(KorayLiman): This function doesn't support localization. It has to be implemented (Jiffy paketi ??)
    CoreLogger.log(
      "This function doesn't support localization. It has to be implemented",
      color: LogColors.yellow,
    );

    final difference = DateTime.now().difference(this);
    return switch (difference.inSeconds) {
      < 30 => 'Şimdi',
      < 60 => '${difference.inSeconds} saniye önce',
      < 60 * 60 => '${difference.inMinutes} dakika önce',
      < 24 * 60 * 60 => '${difference.inHours} saat önce',
      _ => '${difference.inDays} gün önce',
    };
  }

  /// Formats the date as 'd MMMM EEEE' eg. 3 Nisan Cumartesi
  String todMMMMEEEE({String? locale}) {
    return DateFormat('d MMMM EEEE', locale).format(this);
  }

  /// Formats the date as 'd MMMM y' eg. 3 Nisan 2022
  String todMMMMMy({String? locale}) {
    return DateFormat('d MMMM y', locale).format(this);
  }

  /// Formats the date as 'MMMM y' eg. Nisan 2022
  String toMMMMy({String? locale}) {
    return DateFormat('MMMM y', locale).format(this);
  }

  /// Formats the date as 'd MMMM' eg. 3 Nisan
  String todMMMM({String? locale}) {
    return DateFormat('d MMMM', locale).format(this);
  }

  /// Formats the date as 'd MMMM y H:m' eg. 3 Nisan 2022 12:00
  String todMMMMyHHmm({String? locale}) {
    return DateFormat('d MMMM y HH:mm', locale).format(this);
  }

  /// Formats the date as 'd MMMM H:m' eg. 3 Nisan 12:00
  String todMMMMHHmm({String? locale}) {
    return DateFormat('d MMMM HH:mm', locale).format(this);
  }

  /// Formats the date as 'H:m' eg. 12:00
  String get toHHmm {
    return DateFormat('HH:mm').format(this);
  }

  /// Formats the date as 'd.MM.y HH:mm:ss' eg. 03.04.2022 12:00:00
  String get toddMMyHHmmss {
    return DateFormat('dd.MM.y HH:mm:ss').format(this);
  }

  /// Formats the date as 'd.MM.y HH:mm' eg. 03.04.2022 12:00
  String get toddMMyHHmm {
    return DateFormat('dd.MM.y HH:mm').format(this);
  }

  /// Formats the date as 'd.MM.y' eg. 03.04.2022
  String get toddMMy {
    return DateFormat('dd.MM.y').format(this);
  }

  /// Formats the date as 'y.MM.dd' eg. 2022.04.03
  String get toyMMdd {
    return DateFormat('y.MM.dd').format(this);
  }

  /// Formats the date as 'yyyy-MM-dd' eg. 2022-04-03
  String get toyyyyMMdd {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Formats the date as 'yyyy-MM-dd HH:mm:ss' eg. 2022-04-03 12:00:00
  String get toyyyyMMddHHmmss {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  /// Prints total number of days in current month
  int get totalDaysInCurrentMonth {
    final range = DateTimeRange(start: DateTime(year, month), end: DateTime(year, month + 1));
    return range.duration.inDays;
  }

  /// Checks if two dates are on the same day
  ///
  /// Compares only year, month and day
  ///
  /// Example:
  ///
  /// final date1 = DateTime(2024,01,01,15,00);
  ///
  /// final date2 = DateTime(2024,01,01,12,00);
  ///
  /// print(date1.isSameDate(date2)); // true
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Checks if the date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if the date is current month and year
  bool get isCurrentMonthAndYear {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}
