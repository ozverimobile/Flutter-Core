import 'package:flutter_core/flutter_core.dart';

/// [List<String>] EXTENSION
extension ListStringToSelectableSheetExtension on List<String?>? {
  List<SelectableSearchString> toSelectableSearchList({bool Function(String query)? customFilter}) {
    return this?.where((x) => x.toNullIfEmpty != null).map((e) => SelectableSearchString(e, customFilter: customFilter)).toList() ?? [];
  }
}

/// [String] EXTENSION
extension StringToSelectableSheetExtension on List<String?>? {
  SelectableSearchString toSelectableSearch({bool Function(String query)? customFilter}) {
    return SelectableSearchString(this?.first, customFilter: customFilter);
  }
}

/// [List<num>] EXTENSION
extension ListNumToSelectableSheetExtension on List<num?>? {
  List<SelectableSearchNum> toSelectableSearch({bool Function(String query)? customFilter}) {
    return this?.where((x) => x != null).map((e) => SelectableSearchNum(e, customFilter: customFilter)).toList() ?? [];
  }
}

/// [num] EXTENSION
extension NumToSelectableSheetExtension on List<num?>? {
  List<SelectableSearchNum> toSelectableSearchList({bool Function(String query)? customFilter}) {
    return this?.where((x) => x != null).map((e) => SelectableSearchNum(e, customFilter: customFilter)).toList() ?? [];
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
