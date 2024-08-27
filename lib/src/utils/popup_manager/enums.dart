import 'package:flutter/cupertino.dart';

enum AdaptiveDatePickerMode {
  date,
  time,
  dateAndTime;

  CupertinoDatePickerMode get toCupertinoDatePickerMode {
    switch (this) {
      case AdaptiveDatePickerMode.date:
        return CupertinoDatePickerMode.date;
      case AdaptiveDatePickerMode.time:
        return CupertinoDatePickerMode.time;
      case AdaptiveDatePickerMode.dateAndTime:
        return CupertinoDatePickerMode.dateAndTime;
    }
  }
}
