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
  
    required this.isPhysicalDevice,
    required this.board,
    required this.bootloader,
    required this.display,
    required this.fingerprint,
    required this.hardware,
    required this.host,
    required this.supported32BitAbis,
    required this.supported64BitAbis,
    required this.supportedAbis,
    required this.tags,
    required this.type,
    required this.systemFeatures,
    required this.isLowRamDevice,
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

  

  /// `false` if the application is running in an emulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// The name of the underlying board, like "goldfish".
  /// https://developer.android.com/reference/android/os/Build#BOARD
  final String board;

  /// The system bootloader version number.
  /// https://developer.android.com/reference/android/os/Build#BOOTLOADER
  final String bootloader;

  /// A build ID string meant for displaying to the user.
  /// https://developer.android.com/reference/android/os/Build#DISPLAY
  final String display;

  /// A string that uniquely identifies this build.
  /// https://developer.android.com/reference/android/os/Build#FINGERPRINT
  final String fingerprint;

  /// The name of the hardware (from the kernel command line or /proc).
  /// https://developer.android.com/reference/android/os/Build#HARDWARE
  final String hardware;

  /// Hostname.
  /// https://developer.android.com/reference/android/os/Build#HOST
  final String host;

  /// An ordered list of 32 bit ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_32_BIT_ABIS
  final List<String> supported32BitAbis;

  /// An ordered list of 64 bit ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_64_BIT_ABIS
  final List<String> supported64BitAbis;

  /// An ordered list of ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_ABIS
  final List<String> supportedAbis;

  /// Comma-separated tags describing the build, like "unsigned,debug".
  /// https://developer.android.com/reference/android/os/Build#TAGS
  final String tags;

  /// The type of build, like "user" or "eng".
  /// https://developer.android.com/reference/android/os/Build#TIME
  final String type;

  /// Describes what features are available on the current device.
  ///
  /// This can be used to check if the device has, for example, a front-facing
  /// camera, or a touchscreen. However, in many cases this is not the best
  /// API to use. For example, if you are interested in bluetooth, this API
  /// can tell you if the device has a bluetooth radio, but it cannot tell you
  /// if bluetooth is currently enabled, or if you have been granted the
  /// necessary permissions to use it. Please *only* use this if there is no
  /// other way to determine if a feature is supported.
  ///
  /// This data comes from Android's PackageManager.getSystemAvailableFeatures,
  /// and many of the common feature strings to look for are available in
  /// PackageManager's public documentation:
  /// https://developer.android.com/reference/android/content/pm/PackageManager
  final List<String> systemFeatures;

  /// `true` if the application is running on a low-RAM device, `false` otherwise.
  final bool isLowRamDevice;

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
     
        'isPhysicalDevice: $isPhysicalDevice'
        ')';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is CoreAndroidDeviceInfo && runtimeType == other.runtimeType && baseOS == other.baseOS && codename == other.codename && incremental == other.incremental && previewSdkInt == other.previewSdkInt && release == other.release && sdkInt == other.sdkInt && securityPatch == other.securityPatch && brand == other.brand && device == other.device && id == other.id && manufacturer == other.manufacturer && model == other.model && product == other.product && isPhysicalDevice == other.isPhysicalDevice;

  @override
  int get hashCode => baseOS.hashCode ^ codename.hashCode ^ incremental.hashCode ^ previewSdkInt.hashCode ^ release.hashCode ^ sdkInt.hashCode ^ securityPatch.hashCode ^ brand.hashCode ^ device.hashCode ^ id.hashCode ^ manufacturer.hashCode ^ model.hashCode ^ product.hashCode ^ isPhysicalDevice.hashCode;
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
    required this.utsname,
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

  /// Operating system information derived from `sys/utsname.h`.
  final CoreIosUtsname utsname;

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
        ', utsname: $utsname'
        ')';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is CoreIosDeviceInfo && runtimeType == other.runtimeType && name == other.name && systemName == other.systemName && systemVersion == other.systemVersion && model == other.model && localizedModel == other.localizedModel && identifierForVendor == other.identifierForVendor && isPhysicalDevice == other.isPhysicalDevice;

  @override
  int get hashCode => name.hashCode ^ systemName.hashCode ^ systemVersion.hashCode ^ model.hashCode ^ localizedModel.hashCode ^ identifierForVendor.hashCode ^ isPhysicalDevice.hashCode;
}

class CoreIosUtsname {
  const CoreIosUtsname({
    required this.sysname,
    required this.nodename,
    required this.release,
    required this.version,
    required this.machine,
  });

  /// Operating system name.
  final String? sysname;

  /// Network node name.
  final String? nodename;

  /// Release level.
  final String? release;

  /// Version level.
  final String? version;

  /// Hardware type (e.g. 'iPhone7,1' for iPhone 6 Plus).
  final String? machine;

  @override
  String toString() {
    return 'CoreIosUtsname('
        'sysname: $sysname, '
        'nodename: $nodename, '
        'release: $release, '
        'version: $version, '
        'machine: $machine'
        ')';
  }
}
