import 'dart:convert';
import 'dart:io';

import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/common/patch_platform/patch_platform.dart';

abstract interface class ICoreCodePushManager {}

class CoreCodePushManager implements ICoreCodePushManager {
  CoreCodePushManager._();

  static final instance = CoreCodePushManager._();

  @deprecated
  Future<bool> isPatchUpdateForced({
    required FirebaseRemoteConfig remoteConfigInstance,
    required int? currentPatchNumber,
    required int nextPatchNumber,
  }) async {
    try {
      final isSuccess = await remoteConfigInstance.fetchAndActivate();

      final version = await CorePackageInfo.instance.version;
      if (version.isNull || !isSuccess) return false;

      final patchesString = remoteConfigInstance.getString(Platform.isAndroid ? 'patchesOnAndroid' : 'patchesOnIOS');
      if (patchesString.isEmpty) return false;
      final patchesJson = jsonDecode(patchesString);
      if (patchesJson is! List) return false;

      final patches = patchesJson.cast<Map<String, dynamic>>().map(PatchPlatform.fromJson).toList().firstWhereOrNull((element) => element.version == version)?.patches;

      if (patches.isNullOrEmpty) return false;

      if (currentPatchNumber.isNull) {
        for (final patch in patches!) {
          if (patch.patchNumber.isNotNull && patch.patchNumber! <= nextPatchNumber && (patch.forceUpdate ?? false)) {
            return true;
          }
        }
      } else {
        for (final patch in patches!) {
          if (patch.patchNumber.isNotNull && patch.patchNumber! > currentPatchNumber! && patch.patchNumber! <= nextPatchNumber && (patch.forceUpdate ?? false)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Patch?> getLatestPatchInfo({
    required FirebaseRemoteConfig remoteConfigInstance,
    required int? currentPatchNumber,
    required int nextPatchNumber,
  }) async {
    try {
      final isSuccess = await remoteConfigInstance.fetchAndActivate();

      final version = await CorePackageInfo.instance.version;
      if (version.isNull || !isSuccess) return null;

      final patchesString = remoteConfigInstance.getString(Platform.isAndroid ? 'patchesOnAndroid' : 'patchesOnIOS');
      if (patchesString.isEmpty) return null;
      final patchesJson = jsonDecode(patchesString);
      if (patchesJson is! List) return null;

      final patches = patchesJson.cast<Map<String, dynamic>>().map(PatchPlatform.fromJson).toList().firstWhereOrNull((element) => element.version == version)?.patches;

      if (patches.isNullOrEmpty) return null;

      var isForce = false;

      if (currentPatchNumber.isNull) {
        for (final patch in patches!) {
          if (patch.patchNumber.isNotNull && patch.patchNumber! <= nextPatchNumber && (patch.forceUpdate ?? false)) {
            isForce = true;
          }
        }
      } else {
        for (final patch in patches!) {
          if (patch.patchNumber.isNotNull && patch.patchNumber! > currentPatchNumber! && patch.patchNumber! <= nextPatchNumber && (patch.forceUpdate ?? false)) {
            isForce = true;
          }
        }
      }

      return Patch(forceUpdate: isForce, showInfoBottomSheet: patches.lastOrNull?.showInfoBottomSheet, patchNumber: patches.lastOrNull?.patchNumber);
    } catch (e) {
      return null;
    }
  }
}
