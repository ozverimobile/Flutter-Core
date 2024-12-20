import 'package:flutter/material.dart';

@immutable
class IndicatorStyle {
  const IndicatorStyle({
    this.radius,
    this.strokeWidth,
    this.color,
  });

  /// The radius of the indicator.
  final double? radius;

  /// The stroke width of the indicator (Only valid for Android).
  final double? strokeWidth;

  /// The color of the indicator.
  final Color? color;

  /// The default radius of the indicator.
  static const double defaultRadius = 10;

  /// The default stroke width of the indicator (Only valid for Android).
  static const double defaultStrokeWidth = 4;
}
