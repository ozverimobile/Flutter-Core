import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
final class MaintenanceModeInfo with BaseModel<MaintenanceModeInfo> {
  const MaintenanceModeInfo({
    this.isMaintenanceModeActive,
    this.title,
    this.content,
    this.maintenanceIcon,
    this.userIds,
    this.url,
  });

  factory MaintenanceModeInfo.fromJson(Map<String, dynamic> json) {
    return MaintenanceModeInfo(
      isMaintenanceModeActive: json['isMaintenanceModeActive'] as bool?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      maintenanceIcon: json['maintenanceIcon'] as String?,
      userIds: (json['userIds'] as List<dynamic>?)?.cast<String>(),
      url: json['url'] as String?,
    );
  }

  /// If `true`, maintenance mode is shown. If `null` or `false`, it is not shown.
  final bool? isMaintenanceModeActive;

  /// Title shown on the maintenance screen. Falls back to a default message when `null`.
  final String? title;

  /// Content shown on the maintenance screen. Falls back to a default message when `null`.
  final String? content;

  /// Icon url shown on the maintenance screen. Falls back to a default icon when `null`.
  final String? maintenanceIcon;

  /// User ids the maintenance screen is shown to. Shown to everyone when `null` or empty.
  final List<String>? userIds;

  /// When provided, the default screen shows a "Daha Fazla Bilgi" button that opens
  /// this url via [CoreUrlLauncher] instead of using its primary action for retry.
  final String? url;

  @override
  MaintenanceModeInfo fromJson(Map<String, Object?> json) => MaintenanceModeInfo.fromJson(json);

  @override
  Map<String, Object?> toJson() => {
        'isMaintenanceModeActive': isMaintenanceModeActive,
        'title': title,
        'content': content,
        'maintenanceIcon': maintenanceIcon,
        'userIds': userIds,
        'url': url,
      };

  @override
  String toString() {
    return 'MaintenanceModeInfo(isMaintenanceModeActive: $isMaintenanceModeActive, title: $title, content: $content, maintenanceIcon: $maintenanceIcon, userIds: $userIds, url: $url)';
  }
}
