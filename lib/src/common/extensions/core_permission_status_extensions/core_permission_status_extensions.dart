import 'package:flutter_core/flutter_core.dart';

/// [CorePermissionStatus] EXTENSIONS
extension CorePermissionStatusExtensions on CorePermissionStatus {
  /// If the user granted access to the requested feature.
  bool get isGranted => this == CorePermissionStatus.granted;

  /// If the permission to the requested feature is permanently denied, the
  /// permission dialog will not be shown when requesting this permission. The
  /// user may still change the permission status in the settings.
  ///
  /// *On Android:*
  /// Android 11+ (API 30+): whether the user denied the permission for a second
  /// time.
  /// Below Android 11 (API 30): whether the user denied access to the requested
  /// feature and selected to never again show a request.
  /// The user may still change the permission status in the settings.
  ///
  /// *On iOS:*
  /// If the user has denied access to the requested feature.
  bool get isPermanentlyDenied => this == CorePermissionStatus.permanentlyDenied;

  /// If the user denied access to the requested feature.
  /// The user may still change the permission status in the settings.
  bool get isNeverPrompted => this == CorePermissionStatus.neverPrompted;

  /// If the user denied access to the requested feature.
  /// The user may still change the permission status in the settings.
  bool get isPostponed => this == CorePermissionStatus.postponed;
}

/// [CorePermissionStatus] EXTENSIONS
extension FutureCorePermissionStatusExtensions on Future<CorePermissionStatus> {
  /// If the user granted access to the requested feature.
  Future<bool> get isGranted async => (await this).isGranted;

  /// If the permission to the requested feature is permanently denied, the
  /// permission dialog will not be shown when requesting this permission. The
  /// user may still change the permission status in the settings.
  ///
  /// *On Android:*
  /// Android 11+ (API 30+): whether the user denied the permission for a second
  /// time.
  /// Below Android 11 (API 30): whether the user denied access to the requested
  /// feature and selected to never again show a request.
  /// The user may still change the permission status in the settings.
  ///
  /// *On iOS:*
  /// If the user has denied access to the requested feature.
  Future<bool> get isPermanentlyDenied async => (await this).isPermanentlyDenied;

  /// If the user denied access to the requested feature.
  /// The user may still change the permission status in the settings.
  Future<bool> get isNeverPrompted async => (await this).isNeverPrompted;

  /// If the user denied access to the requested feature.
  /// The user may still change the permission status in the settings.
  Future<bool> get isPostponed async => (await this).isPostponed;
}
