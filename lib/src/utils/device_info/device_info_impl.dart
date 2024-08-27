import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_core/src/utils/device_info/protocol/protocol.dart';

abstract interface class ICoreDeviceInfo {
  Future<CoreAndroidDeviceInfo> get androidInfo;

  Future<CoreIosDeviceInfo> get iosInfo;

  Future<String?> get deviceName;
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
    );
  }

  @override
  Future<String?> get deviceName async {
    return Platform.isIOS ? _getIosDeviceName : _getAndroidDeviceName;
  }

  Future<String?> get _getIosDeviceName async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    return iosInfo.identifierForVendor ?? iosInfo.localizedModel;
  }

  Future<String?> get _getAndroidDeviceName async {
    // TODO(Huseyin): Hüseyinin yaptığı android id kütüphanesi eklenecek.
    return null;
  }
}
