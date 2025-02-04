enum PermissionManagerKeys {
  notificationPermissionButtonKey,
  cameraPermissionButtonKey,
  photosPermissionButtonKey,
  notificationPermissionStatusKey,
  cameraPermissionStatusKey,
  photosPermissionStatusKey,
}

extension PermissionManagerKeysExtension on PermissionManagerKeys {
  String get rawValue => toString();
}
