import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
final class PatchPlatform with BaseModel<PatchPlatform> {
  const PatchPlatform({
    this.version,
    this.patches,
  });

  factory PatchPlatform.fromJson(Map<String, dynamic> json) {
    return PatchPlatform(
      version: json['version'] as String?,
      patches: (json['patches'] as List<dynamic>?)?.map((e) => Patch.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String? version;
  final List<Patch>? patches;

  @override
  PatchPlatform fromJson(Map<String, Object?> json) => PatchPlatform.fromJson(json);

  @override
  Map<String, Object?> toJson() => {
        'version': version,
        'patches': patches?.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() {
    return 'PatchPlatformDto(version: $version, patches: $patches)';
  }
}

@immutable
final class Patch with BaseModel<Patch> {
  const Patch({
    this.patchNumber,
    this.forceUpdate,
    this.showInfoBottomSheet,
  });

  factory Patch.fromJson(Map<String, dynamic> json) {
    return Patch(
      patchNumber: json['patchNumber'] as int?,
      forceUpdate: json['forceUpdate'] as bool?,
      showInfoBottomSheet: json['showInfoBottomSheet'] as bool?,
    );
  }

  final int? patchNumber;
  final bool? forceUpdate;
  final bool? showInfoBottomSheet;

  @override
  Patch fromJson(Map<String, Object?> json) => Patch.fromJson(json);

  @override
  Map<String, Object?> toJson() => {
        'patchNumber': patchNumber,
        'forceUpdate': forceUpdate,
        'showInfoBottomSheet': showInfoBottomSheet,
      };

  @override
  String toString() {
    return 'Patch(patchNumber: $patchNumber, forceUpdate: $forceUpdate, showInfoBottomSheet: $showInfoBottomSheet)';
  }
}
