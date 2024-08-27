/// [Object] EXTENSION
extension ObjectExtensionNullable on Object? {
  /// Returns true if object is null
  bool get isNull => this == null;

  /// Returns true if object is not null
  bool get isNotNull => this != null;
}
