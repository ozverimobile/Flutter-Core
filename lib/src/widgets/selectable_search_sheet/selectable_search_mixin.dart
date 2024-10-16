/// Base class for selectable search items.
/// ```dart
///class Example implements SelectableSearchBase {
///  Example({required this.isActive, required this.name, required this.description});
///
///  final bool isActive;
///  final String name;
///  final String? description;
///
///  @override
///  bool get active => isActive;
///
///  @override
///  bool Function(String query) get filter => (query) => name.toLowerCase().contains(query.toLowerCase());
///
///  @override
///  String? get subtitle => name;
///
///  @override
///  String? get title => description;
///}
/// ```
library;

import 'package:flutter/cupertino.dart';

@immutable
mixin SelectableSearchMixin {
  String? get title;
  String? get subtitle;
  bool get active;
  bool filter(String query);
}
