import 'package:permission_handler/permission_handler.dart';

enum CorePermissionStatus {
  /// The user denied access to the requested feature, permission needs to be
  /// asked first.
  neverPrompted,

  /// The user granted access to the requested feature.
  granted,

  /// The permission is postponed.
  ///
  /// When requestPermission is called request dialog will not be shown.
  postponed,

  /// Permission to the requested feature is permanently denied, the permission
  /// dialog will not be shown when requesting this permission. The user may
  /// still change the permission status in the settings.
  ///
  /// *On Android:*
  /// Android 11+ (API 30+): whether the user denied the permission for a second
  /// time.
  /// Below Android 11 (API 30): whether the user denied access to the requested
  /// feature and selected to never again show a request.
  ///
  /// *On iOS:*
  /// If the user has denied access to the requested feature.
  permanentlyDenied;

  static CorePermissionStatus fromPermissionStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted || PermissionStatus.limited => CorePermissionStatus.granted,
      PermissionStatus.denied => CorePermissionStatus.neverPrompted,
      PermissionStatus.permanentlyDenied => CorePermissionStatus.permanentlyDenied,
      _ => throw Exception('Unknown permission status: $status'),
    };
  }
}
