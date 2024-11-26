extension StringExtension on String {
  /// Returns true if given string is a valid email
  bool get isEmail {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(this);
  }
}

extension StringExtensionNullable on String? {
  /// Returns true if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if string is not null or not empty
  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;

  /// returns null if string is empty
  String? get toNullIfEmpty => (this ?? '') == '' ? null : this;

  /// Truncates the string to the given length
  String? truncateToLength({int length = 25, String suffix = '...'}) => this != null && this!.length > length ? '${this!.substring(0, length)}$suffix' : this;
}
