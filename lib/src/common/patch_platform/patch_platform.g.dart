// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_platform_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchPlatformDto _$PatchPlatformDtoFromJson(Map<String, dynamic> json) =>
    PatchPlatformDto(
      version: json['version'] as String?,
      patches: (json['patches'] as List<dynamic>?)
          ?.map((e) => Patch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PatchPlatformDtoToJson(PatchPlatformDto instance) =>
    <String, dynamic>{
      'version': instance.version,
      'patches': instance.patches,
    };

Patch _$PatchFromJson(Map<String, dynamic> json) => Patch(
      patchNumber: (json['patchNumber'] as num?)?.toInt(),
      forceUpdate: json['forceUpdate'] as bool?,
    );

Map<String, dynamic> _$PatchToJson(Patch instance) => <String, dynamic>{
      'patchNumber': instance.patchNumber,
      'forceUpdate': instance.forceUpdate,
    };
