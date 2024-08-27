import 'dart:io';

import 'package:flutter_core/flutter_core.dart';
import 'package:url_launcher/url_launcher.dart';

abstract interface class ICoreUrlLauncher {
  Future<bool> launchWebUrl({required String url});
  Future<bool> launchEmail({required String email, String? subject});
  Future<bool> launchPhone({required String phoneNumber});
  Future<bool> launchSms({required String phoneNumber, String? body});
  Future<bool> launchStore({String? iosAppId, String? androidPackageName, String? huaweiAppId});
  Future<bool> launchDeepLink({required String deepLink});
}

class CoreUrlLauncher implements ICoreUrlLauncher {
  CoreUrlLauncher._();
  static final instance = CoreUrlLauncher._();

  @override
  Future<bool> launchWebUrl({required String url}) async {
    final params = Uri.parse(url);
    if (await canLaunchUrl(params)) {
      return launchUrl(params);
    }
    return false;
  }

  @override
  Future<bool> launchEmail({required String email, String? subject}) async {
    final params = Uri(
      scheme: 'mailto',
      path: email,
      query: subject == null ? null : 'subject=$subject',
    );
    if (await canLaunchUrl(params)) {
      return launchUrl(params);
    }
    return false;
  }

  @override
  Future<bool> launchPhone({required String phoneNumber}) async {
    final params = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(params)) {
      return launchUrl(params);
    }
    return false;
  }

  @override
  Future<bool> launchSms({required String phoneNumber, String? body}) async {
    final params = Uri(
      scheme: 'sms',
      path: phoneNumber,
      query: body == null ? null : 'body=$body',
    );
    if (await canLaunchUrl(params)) {
      return launchUrl(params);
    }
    return false;
  }

  @override
  Future<bool> launchStore({String? iosAppId, String? androidPackageName, String? huaweiAppId}) async {
    String url;
    if (Platform.isAndroid) {
      final isHuawei = await DeviceType.isHuawei();
      if (isHuawei) {
        url = 'https://appgallery.cloud.huawei.com/marketshare/app/$huaweiAppId';
      } else {
        url = 'market://details?id=$androidPackageName';
      }
    } else {
      url = 'https://apps.apple.com/app/id$iosAppId';
    }
    final params = Uri.parse(url);
    if (await canLaunchUrl(params)) {
      return launchUrl(params, mode: LaunchMode.externalNonBrowserApplication);
    }
    return false;
  }

  @override
  Future<bool> launchDeepLink({required String deepLink}) async {
    final uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    }
    return false;
  }
}
