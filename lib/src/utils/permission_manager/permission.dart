import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:permission_handler/permission_handler.dart';

const _permissionKeyPrefix = 'CorePermissionSharedPreferencesPrefix/';

enum CorePermission {
  notification(sharedPrefKey: '${_permissionKeyPrefix}Notification'),
  camera(sharedPrefKey: '${_permissionKeyPrefix}Camera'),
  photos(sharedPrefKey: '${_permissionKeyPrefix}Photos'),
  microphone(sharedPrefKey: '${_permissionKeyPrefix}Microphone'),
  speech(sharedPrefKey: '${_permissionKeyPrefix}Speech'),
  contact(sharedPrefKey: '${_permissionKeyPrefix}Contact');

  const CorePermission({required this.sharedPrefKey});

  final String sharedPrefKey;

  Future<Permission> permission() async {
    return switch (this) {
      CorePermission.notification => Permission.notification,
      CorePermission.camera => Permission.camera,
      CorePermission.photos => Platform.isAndroid
          ? (await CoreDeviceInfo.instance.androidInfo).sdkInt <= 32
              ? Permission.storage
              : Permission.photos
          : Permission.photos,
      CorePermission.microphone => Permission.microphone,
      CorePermission.speech => Permission.speech,
      CorePermission.contact => Permission.contacts,
    };
  }

  Future<String> title() async {
    return switch (this) {
      CorePermission.notification => 'Bildirim İzni',
      CorePermission.camera => 'Kamera İzni',
      CorePermission.photos => 'Fotoğraf İzni',
      CorePermission.microphone => 'Mikrofon İzni',
      CorePermission.speech => 'Konuşma İzni',
      CorePermission.contact => 'Rehber İzni',
    };
  }

  Future<String> message() async {
    final appName = await CorePackageInfo.instance.appName;
    return switch (this) {
      CorePermission.notification => '$appName bildirimleri alabilmeniz için izin istiyor',
      CorePermission.camera => '$appName kamerayı kullanabilmeniz için izin istiyor',
      CorePermission.photos => '$appName fotoğraflara erişebilmeniz için izin istiyor',
      CorePermission.microphone => '$appName mikrofonu kullanabilmeniz için izin istiyor',
      CorePermission.speech => '$appName konuşma tanıma yapabilmeniz için izin istiyor',
      CorePermission.contact => '$appName rehberi kullanabilmeniz için izin istiyor',
    };
  }

  Widget icon(BuildContext context) {
    return switch (this) {
      CorePermission.notification => Icon(
          Icons.notifications,
          size: 50,
          color: context.colorScheme.onPrimary,
        ),
      CorePermission.camera => Icon(
          Icons.camera_alt,
          size: 50,
          color: context.colorScheme.onPrimary,
        ),
      CorePermission.photos => Icon(
          Icons.photo,
          size: 50,
          color: context.colorScheme.onPrimary,
        ),
      CorePermission.microphone || CorePermission.speech => Icon(
          Icons.mic,
          size: 50,
          color: context.colorScheme.onPrimary,
        ),
      CorePermission.contact => Icon(
          Icons.contact_phone,
          size: 50,
          color: context.colorScheme.onPrimary,
        ),
    };
  }
}
