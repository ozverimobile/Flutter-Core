import 'package:flutter/foundation.dart';

@immutable
class CoreAndroidDeviceInfo {
  const CoreAndroidDeviceInfo({
    required this.baseOS,
    required this.codename,
    required this.incremental,
    required this.previewSdkInt,
    required this.release,
    required this.sdkInt,
    required this.securityPatch,
    required this.brand,
    required this.device,
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.product,
    required this.serialNumber,
    required this.isPhysicalDevice,
  });

  /// The base OS build the product is based on.
  /// Available only on Android M (API 23) and newer
  final String? baseOS;

  /// The current development codename, or the string "REL" if this is a release build.
  final String codename;

  /// The internal value used by the underlying source control to represent this build.
  /// Available only on Android M (API 23) and newer
  final String incremental;

  /// The developer preview revision of a pre-release SDK.
  final int? previewSdkInt;

  /// The user-visible version string.
  final String release;

  /// The user-visible SDK version of the framework.
  ///
  /// Possible values are defined in: https://developer.android.com/reference/android/os/Build.VERSION_CODES.html
  final int sdkInt;

  /// The user-visible security patch level.
  /// Available only on Android M (API 23) and newer
  final String? securityPatch;

  /// The consumer-visible brand with which the product/hardware will be associated, if any.
  /// https://developer.android.com/reference/android/os/Build#BRAND
  final String brand;

  /// The name of the industrial design.
  /// https://developer.android.com/reference/android/os/Build#DEVICE
  final String device;

  /// Either a changelist number, or a label like "M4-rc20".
  /// https://developer.android.com/reference/android/os/Build#ID
  final String id;

  /// The manufacturer of the product/hardware.
  /// https://developer.android.com/reference/android/os/Build#MANUFACTURER
  final String manufacturer;

  /// The end-user-visible name for the end product.
  /// https://developer.android.com/reference/android/os/Build#MODEL
  final String model;

  /// The name of the overall product.
  /// https://developer.android.com/reference/android/os/Build#PRODUCT
  final String product;

  /// Hardware serial number of the device, if available
  ///
  /// There are special restrictions on this identifier, more info here:
  /// https://developer.android.com/reference/android/os/Build#getSerial()
  final String serialNumber;

  /// `false` if the application is running in an emulator, `true` otherwise.
  final bool isPhysicalDevice;

  @override
  String toString() {
    return 'AndroidDeviceInfo('
        'baseOS: $baseOS, '
        'codename: $codename, '
        'incremental: $incremental, '
        'previewSdkInt: $previewSdkInt, '
        'release: $release, '
        'sdkInt: $sdkInt, '
        'securityPatch: $securityPatch, '
        'brand: $brand, '
        'device: $device, '
        'id: $id, '
        'manufacturer: $manufacturer, '
        'model: $model, '
        'product: $product, '
        'serialNumber: $serialNumber, '
        'isPhysicalDevice: $isPhysicalDevice'
        ')';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is CoreAndroidDeviceInfo && runtimeType == other.runtimeType && baseOS == other.baseOS && codename == other.codename && incremental == other.incremental && previewSdkInt == other.previewSdkInt && release == other.release && sdkInt == other.sdkInt && securityPatch == other.securityPatch && brand == other.brand && device == other.device && id == other.id && manufacturer == other.manufacturer && model == other.model && product == other.product && serialNumber == other.serialNumber && isPhysicalDevice == other.isPhysicalDevice;

  @override
  int get hashCode => baseOS.hashCode ^ codename.hashCode ^ incremental.hashCode ^ previewSdkInt.hashCode ^ release.hashCode ^ sdkInt.hashCode ^ securityPatch.hashCode ^ brand.hashCode ^ device.hashCode ^ id.hashCode ^ manufacturer.hashCode ^ model.hashCode ^ product.hashCode ^ serialNumber.hashCode ^ isPhysicalDevice.hashCode;
}

@immutable
class CoreIosDeviceInfo {
  const CoreIosDeviceInfo({
    required this.name,
    required this.systemName,
    required this.systemVersion,
    required this.model,
    required this.localizedModel,
    required this.identifierForVendor,
    required this.isPhysicalDevice,
  });

  /// Device name.
  ///
  /// On iOS < 16 returns user-assigned device name
  /// On iOS >= 16 returns a generic device name if project has
  /// no entitlement to get user-assigned device name.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620015-name
  final String name;

  /// The name of the current operating system.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620054-systemname
  final String systemName;

  /// The current operating system version.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620043-systemversion
  final String systemVersion;

  /// Device model.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620044-model
  final String model;

  /// Localized name of the device model.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620029-localizedmodel
  final String localizedModel;

  /// Unique UUID value identifying the current device.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor
  final String? identifierForVendor;

  /// `false` if the application is running in a simulator, `true` otherwise.
  final bool isPhysicalDevice;

  @override
  String toString() {
    return 'IosDeviceInfo('
        'name: $name, '
        'systemName: $systemName, '
        'systemVersion: $systemVersion, '
        'model: $model, '
        'localizedModel: $localizedModel, '
        'identifierForVendor: $identifierForVendor, '
        'isPhysicalDevice: $isPhysicalDevice'
        ')';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is CoreIosDeviceInfo && runtimeType == other.runtimeType && name == other.name && systemName == other.systemName && systemVersion == other.systemVersion && model == other.model && localizedModel == other.localizedModel && identifierForVendor == other.identifierForVendor && isPhysicalDevice == other.isPhysicalDevice;

  @override
  int get hashCode => name.hashCode ^ systemName.hashCode ^ systemVersion.hashCode ^ model.hashCode ^ localizedModel.hashCode ^ identifierForVendor.hashCode ^ isPhysicalDevice.hashCode;
}
