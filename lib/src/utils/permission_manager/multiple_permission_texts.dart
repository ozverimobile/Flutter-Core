import 'package:flutter/foundation.dart';

/// Fixed texts of the multiple permission sheet (see `CorePermissionManager.requestMultiplePermissions`).
///
/// Every field is optional; a missing one falls back to its Turkish default. The content of the
/// sheet itself (title, row labels and descriptions, button labels) is passed to the request
/// method directly, these are the texts that only change with the state of the sheet.
@immutable
final class CoreMultiplePermissionTexts {
  const CoreMultiplePermissionTexts({
    this.incompleteTitle,
    this.incompleteTitleHighlight,
    this.grantedLabel,
    this.deniedLabel,
    this.permanentlyDeniedLabel,
    this.optionalLabel,
    this.optionalNote,
    this.forcedNote,
    this.missingLabel,
    this.missingNote,
  });

  /// First line of the title once the requests are done and some permissions are still missing.
  ///
  /// Default: "Bir izin" / "2 izin", by the number of missing permissions.
  final String? incompleteTitle;

  /// Highlighted second line of [incompleteTitle]. Default: "eksik kaldı."
  final String? incompleteTitleHighlight;

  /// Row caption of a granted permission. Default: "İzin verildi"
  final String? grantedLabel;

  /// Row caption of a denied permission that can still be requested. Default: "Reddedildi"
  final String? deniedLabel;

  /// Row caption of a permission that can only be granted from the app settings.
  ///
  /// Default: "Reddedildi · Ayarlar'dan açabilirsiniz"
  final String? permanentlyDeniedLabel;

  /// Badge of the note when no permission is forced. Default: "İsteğe bağlı"
  final String? optionalLabel;

  /// Note shown when no permission is forced; an empty string hides the note.
  ///
  /// Default: "Bu izinleri (tek izinde "Bu izni") vermeseniz de devam edebilirsiniz. İstediğiniz zaman Ayarlar'dan değiştirebilirsiniz."
  final String? optionalNote;

  /// Note shown when some permissions are forced; an empty string hides the note.
  ///
  /// Its badge is the request method's `forcedLabel`. Default: "İşaretli izinler verilmeden devam
  /// edilemez. Diğerleri isteğe bağlıdır." or, when every permission is forced, "Bu izinler
  /// (tek izinde "Bu izin") verilmeden devam edilemez."
  final String? forcedNote;

  /// Badge of the note when a forced permission is denied. Default: "Gerekli"
  final String? missingLabel;

  /// Note shown when a forced permission is denied; an empty string hides the note.
  ///
  /// Default: "Zorunlu izinler verilmeden devam edilemez. Ayarlar'dan izin verip döndüğünüzde liste kendiliğinden güncellenir."
  final String? missingNote;
}
