/// [List] EXTENSION
extension ListExtensionNullable<T> on List<T>? {
  /// Returns true if list is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if list is not null or not empty
  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;

  /// Returns true if list doesn't contain given object
  bool notContains(T? object) {
    if (this == null || object == null) return true;
    return !this!.contains(object);
  }

  /// Increases or decreases the elements in the list by [times].
  List<T> multiply({required int times}) {
    if (this == null) return [];

    if (this!.isEmpty) throw Exception('List is empty');

    if (times == this!.length) return this!;

    if (times < this!.length) return this!.sublist(0, times);

    final tempList = <T>[];
    var diff = times - this!.length;
    for (;;) {
      var exit = false;
      for (final item in this!) {
        tempList.add(item);
        diff--;
        if (diff == 0) {
          exit = true;
          break;
        }
      }

      if (exit) break;
    }

    this!.addAll(tempList);

    return this!;
  }
}
