import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_core/src/utils/device_info/protocol/protocol.dart';
import 'package:flutter_core/src/utils/platform_channel/platform_channel.dart';

abstract interface class ICoreDeviceInfo {
  Future<CoreAndroidDeviceInfo> get androidInfo;

  Future<CoreIosDeviceInfo> get iosInfo;

  Future<String?> get deviceName;
  Future<String?> get deviceIdentifier;
}

class CoreDeviceInfo implements ICoreDeviceInfo {
  CoreDeviceInfo._();

  static final instance = CoreDeviceInfo._();
  final _deviceInfoPlugin = DeviceInfoPlugin();

  @override
  Future<CoreAndroidDeviceInfo> get androidInfo async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    return CoreAndroidDeviceInfo(
      baseOS: androidInfo.version.baseOS,
      securityPatch: androidInfo.version.securityPatch,
      sdkInt: androidInfo.version.sdkInt,
      previewSdkInt: androidInfo.version.previewSdkInt,
      incremental: androidInfo.version.incremental,
      release: androidInfo.version.release,
      codename: androidInfo.version.codename,
      brand: androidInfo.brand,
      device: androidInfo.device,
      id: androidInfo.id,
      manufacturer: androidInfo.manufacturer,
      model: androidInfo.model,
      product: androidInfo.product,
      isPhysicalDevice: androidInfo.isPhysicalDevice,
      serialNumber: androidInfo.serialNumber,
      hardware: androidInfo.hardware,
      display: androidInfo.display,
      fingerprint: androidInfo.fingerprint,
      host: androidInfo.host,
      tags: androidInfo.tags,
      type: androidInfo.type,
      bootloader: androidInfo.bootloader,
      board: androidInfo.board,
      supported32BitAbis: androidInfo.supported32BitAbis,
      supported64BitAbis: androidInfo.supported64BitAbis,
      supportedAbis: androidInfo.supportedAbis,
      isLowRamDevice: androidInfo.isLowRamDevice,
      systemFeatures: androidInfo.systemFeatures,
    );
  }

  @override
  Future<CoreIosDeviceInfo> get iosInfo async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    return CoreIosDeviceInfo(
      name: iosInfo.name,
      systemName: iosInfo.systemName,
      systemVersion: iosInfo.systemVersion,
      model: iosInfo.model,
      localizedModel: iosInfo.localizedModel,
      identifierForVendor: iosInfo.identifierForVendor,
      isPhysicalDevice: iosInfo.isPhysicalDevice,
      utsname: CoreIosUtsname(
        sysname: iosInfo.utsname.sysname,
        nodename: iosInfo.utsname.nodename,
        release: iosInfo.utsname.release,
        version: iosInfo.utsname.version,
        machine: iosInfo.utsname.machine,
      ),
    );
  }

  @override
  @Deprecated('Use deviceIdentifier instead')
  Future<String?> get deviceName async {
    return Platform.isIOS ? _getIosDeviceIdentifier : _getAndroidDeviceIdentifier;
  }

  @override
  Future<String?> get deviceIdentifier async {
    return Platform.isIOS ? _getIosDeviceIdentifier : _getAndroidDeviceIdentifier;
  }

  Future<String?> get _getIosDeviceIdentifier async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    return iosInfo.identifierForVendor;
  }

  Future<String?> get _getAndroidDeviceIdentifier async {
    return CorePlatformChannel.getAndroidDeviceId();
  }

  Future<bool> isHuaweiApiAvailable() {
    if (!Platform.isAndroid) return Future.value(false);
    try {
      return CorePlatformChannel.isHuaweiApiAvailable();
    } catch (e) {
      throw Exception('Error while checking if Huawei Api available: $e\nFlutter Core Lib: device_info_impl.dart');
    }
  }
}
