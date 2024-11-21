import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_core/src/utils/utils.dart';

enum DeviceType {
  phone,
  tablet,
  desktop;

  static DeviceType get deviceType {
    final mData = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return switch (mData.size.shortestSide) {
      < 600 => DeviceType.phone,
      < 1300 => DeviceType.tablet,
      >= 1300 => DeviceType.desktop,
      _ => throw Exception('Unknown device type, device shortest side: ${mData.size.shortestSide}'),
    };
  }

  static bool isPhone() {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return data.size.shortestSide < 600;
  }

  static bool isTablet() {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return data.size.shortestSide > 600 && data.size.shortestSide < 1300;
  }

  static bool isDesktop() {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return data.size.shortestSide > 1300;
  }

  @Deprecated('Use CoreDeviceInfo.instance.isHuaweiApiAvailable() instead')
  static Future<bool> isHuawei() {
    if (!Platform.isAndroid) return Future.value(false);
    try {
      return CorePlatformChannel.isHuaweiApiAvailable();
    } catch (e) {
      throw Exception('Error while checking if device is Huawei: $e\nFlutter Core Lib: device_type_impl.dart');
    }
  }
}
