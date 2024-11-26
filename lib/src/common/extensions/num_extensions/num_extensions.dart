import 'package:intl/intl.dart';

extension NumExtensions on num? {
  /// Converts the number to a localized price format
  String? toLocalizedPrice({int decimal = 2}) {
    if (this == null) return null;
    final formattedPrice = this!.toStringAsFixed(decimal);
    final decimalPattern = NumberFormat.decimalPattern('tr_TR').format(double.tryParse(formattedPrice));
    if (decimalPattern.contains(',')) {
      final split = decimalPattern.split(',');
      if (split.last.length == 1) {
        return '$decimalPattern' '0';
      } else {
        return '${split.first},${split.last.substring(0, decimal)}';
      }
    } else {
      return "$decimalPattern,${"0" * decimal}";
    }
  }
}
