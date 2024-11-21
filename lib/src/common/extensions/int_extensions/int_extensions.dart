/// [int] EXTENSION
extension IntExtension on int {
  /// Converts to duration object to microseconds of value
  Duration get microseconds => Duration(microseconds: this);

  /// Converts to duration object to milliseconds of value
  Duration get milliseconds => Duration(milliseconds: this);

  /// Converts to duration object to seconds of value
  Duration get seconds => Duration(seconds: this);

  /// Converts to duration object to minutes of value
  Duration get minutes => Duration(minutes: this);

  /// Converts to duration object to hours of value
  Duration get hours => Duration(hours: this);

  /// Converts to duration object to days of value
  Duration get days => Duration(days: this);

  /// Converts bytes to kilobytes
  double get bytesToKilobytes => this / 1024;

  /// Converts bytes to megabytes
  double get bytesToMegabytes => this / (1024 * 1024);

  /// Converts bytes to gigabytes
  double get bytesToGigabytes => this / (1024 * 1024 * 1024);

  /// Converts kilobytes to bytes
  double get kiloBytesToBytes => this * 1024;

  /// Converts kilobytes to megabytes
  double get kiloBytesToMegabytes => this / 1024;

  /// Converts kilobytes to gigabytes
  double get kiloBytesToGigabytes => this / (1024 * 1024);

  /// Converts megabytes to bytes
  double get megaBytesToBytes => this * 1024 * 1024;

  /// Converts megabytes to kilobytes
  double get megaBytesToKilobytes => this * 1024;

  /// Converts megabytes to gigabytes
  double get megaBytesToGigabytes => this / 1024;

  /// Converts gigabytes to bytes
  double get gigaBytesToBytes => this * 1024 * 1024 * 1024;

  /// Converts gigabytes to kilobytes
  double get gigaBytesToKilobytes => this * 1024 * 1024;

  /// Converts gigabytes to megabytes
  double get gigaBytesToMegabytes => this * 1024;
}
