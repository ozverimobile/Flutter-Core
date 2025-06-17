import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/date_symbol_data_local.dart';


abstract interface class ICore {
  Future<void> initialize();
  void closeKeyboard();
  String doubleToCurrency(double value);
  Future<void> updateApp({String? androidPackageName, String? iOSAppId, String? huaweiAppId, bool iosLaunchIntune = false});
  Future<void> vibrate({ImpactType type = ImpactType.mediumImpact});
}
// It's okay to be ignored
// ignore: non_constant_identifier_names
CoreImpl Core = CoreImpl._();

/// Core implementation of the package
final class CoreImpl implements ICore {
  CoreImpl._();

  /// Initializes localizations for date formatting
  @override
  Future<void> initialize() async {
    try {
      await initializeDateFormatting();
    } catch (e) {
      CoreLogger.log(e, color: LogColors.red);
      rethrow;
    }
  }

  /// Closes the keyboard
  @override
  void closeKeyboard() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus?.hasFocus ?? false) {
      primaryFocus!.unfocus();
    } else {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  /// Converts a double value to a currency string
  @override
  String doubleToCurrency(double value) {
    final valueIsNegative = value < 0;
    final newValue = valueIsNegative ? value.abs() : value;

    // Değeri tam sayı ve ondalık kısmına ayır
    final wholePart = newValue.floor();
    final fractionalPart = ((newValue - wholePart) * 100).round();

    // Tam sayı kısmını tersine çevirerek üçlü gruplara ayır
    final wholePartReversed = wholePart.toString().split('').reversed.join();
    final wholePartGroupedReversed = StringBuffer();
    for (var i = 0; i < wholePartReversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        wholePartGroupedReversed.write('.');
      }
      wholePartGroupedReversed.write(wholePartReversed[i]);
    }

    // Tam sayı kısmını tekrar ters çevir
    final wholePartGrouped = wholePartGroupedReversed.toString().split('').reversed.join();

    // Sonuç dizeyi oluştur
    final result = '$wholePartGrouped,${fractionalPart.toString().padLeft(2, '0')}';
    return valueIsNegative ? '-$result' : result;
  }

  @override
  Future<void> updateApp({
    String? androidPackageName,
    String? iOSAppId,
    String? huaweiAppId,
    bool iosLaunchIntune = false,
  }) async {
    const intuneCompanyPortalIosUrlScheme = 'companyportal://';
    const intuneCompanyPortalIosAppId = '719171358';

    final isHuawei = await CoreDeviceInfo.instance.isHuaweiApiAvailable();
    if (isHuawei) {
      // Launch App Gallery
      await CoreUrlLauncher.instance.launchStore(huaweiAppId: huaweiAppId);
      return;
    }

    if (Platform.isAndroid) {
      try {
        final updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
          await InAppUpdate.performImmediateUpdate();
        } else {
          await CoreUrlLauncher.instance.launchStore(androidPackageName: androidPackageName);
        }
      } catch (e) {
        // If an exception occurs launch Play Store
        await CoreUrlLauncher.instance.launchStore(
          androidPackageName: androidPackageName,
        );
      }
    } else {
      if (iosLaunchIntune) {
        final result = await CoreUrlLauncher.instance.launchDeepLink(deepLink: intuneCompanyPortalIosUrlScheme);
        if (!result) {
          await CoreUrlLauncher.instance.launchStore(iosAppId: intuneCompanyPortalIosAppId);
        }
      } else {
        // Launch App Store
        await CoreUrlLauncher.instance.launchStore(iosAppId: iOSAppId);
      }
    }
  }

  @override
  Future<void> vibrate({ImpactType type = ImpactType.mediumImpact}) {
    return switch (type) {
      ImpactType.vibrate => HapticFeedback.vibrate(),
      ImpactType.lightImpact => HapticFeedback.lightImpact(),
      ImpactType.mediumImpact => HapticFeedback.mediumImpact(),
      ImpactType.heavyImpact => HapticFeedback.heavyImpact(),
      ImpactType.selectionClick => HapticFeedback.selectionClick(),
    };
  }
}
