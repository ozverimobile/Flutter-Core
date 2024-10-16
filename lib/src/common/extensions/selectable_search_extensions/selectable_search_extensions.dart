import 'package:flutter_core/flutter_core.dart';

/// [List<String>] EXTENSION
extension StringToSelectableSheetExtension on List<String?>? {
  List<SelectableSearchString> toSelectableSearchList({bool Function(String query)? customFilter}) {
    return this?.map((e) => SelectableSearchString(e, customFilter: customFilter)).toList() ?? [];
  }
}

/// [List<num>] EXTENSION
extension NumToSelectableSheetExtension on List<num?>? {
  List<SelectableSearchNum> toSelectableSearchList({bool Function(String query)? customFilter}) {
    return this?.map((e) => SelectableSearchNum(e, customFilter: customFilter)).toList() ?? [];
  }
}

/// Default implementation of [SelectableSearchMixin]
class SelectableSearchString implements SelectableSearchMixin {
  const SelectableSearchString(this.value, {this.customFilter});
  final String? value;
  final bool Function(String query)? customFilter;

  @override
  String? get title => value ?? '';

  @override
  String? get subtitle => null;

  @override
  bool get active => true;

  @override
  bool filter(String query) {
    return customFilter?.call(query) ?? value!.toLowerCase().contains(query.toLowerCase());
  }

  @override
  bool operator ==(Object other) {
    return (other is SelectableSearchString) && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Default implementation of [SelectableSearchMixin]
class SelectableSearchNum implements SelectableSearchMixin {
  const SelectableSearchNum(this.value, {this.customFilter});
  final num? value;
  final bool Function(String query)? customFilter;

  @override
  String? get title => value?.toString() ?? '';

  @override
  String? get subtitle => null;

  @override
  bool get active => true;

  @override
  bool filter(String query) {
    return customFilter?.call(query) ?? value?.toString().toLowerCase().contains(query.toLowerCase()) ?? false;
  }

  @override
  bool operator ==(Object other) {
    return (other is SelectableSearchNum) && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
