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
  location(sharedPrefKey: '${_permissionKeyPrefix}Location'),
  contact(sharedPrefKey: '${_permissionKeyPrefix}Contact'),

  /// Yakindaki Bluetooth cihazlarini tarama. Android 12+ `BLUETOOTH_SCAN`;
  /// iOS'ta tek Bluetooth izni oldugu icin [bluetoothConnect] ile ayni izindir.
  bluetoothScan(sharedPrefKey: '${_permissionKeyPrefix}BluetoothScan'),

  /// Eslesmis Bluetooth cihazina baglanma. Android 12+ `BLUETOOTH_CONNECT`;
  /// iOS'ta [bluetoothScan] ile ayni izindir.
  bluetoothConnect(sharedPrefKey: '${_permissionKeyPrefix}BluetoothConnect');

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
      CorePermission.location => Permission.location,
      CorePermission.bluetoothScan => Platform.isIOS ? Permission.bluetooth : Permission.bluetoothScan,
      CorePermission.bluetoothConnect => Platform.isIOS ? Permission.bluetooth : Permission.bluetoothConnect,
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
      CorePermission.location => 'Konum İzni',
      CorePermission.bluetoothScan => 'Bluetooth Tarama İzni',
      CorePermission.bluetoothConnect => 'Bluetooth Bağlantı İzni',
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
      CorePermission.location => '$appName konum bilgilerinizi kullanabilmemiz için izin istiyor',
      CorePermission.bluetoothScan => '$appName yakındaki Bluetooth cihazlarını bulabilmeniz için izin istiyor',
      CorePermission.bluetoothConnect => '$appName Bluetooth cihazlarına bağlanabilmeniz için izin istiyor',
    };
  }

  IconData get iconData {
    return switch (this) {
      CorePermission.notification => Icons.notifications,
      CorePermission.camera => Icons.camera_alt,
      CorePermission.photos => Icons.photo,
      CorePermission.microphone || CorePermission.speech => Icons.mic,
      CorePermission.contact => Icons.contact_phone,
      CorePermission.location => Icons.location_on,
      CorePermission.bluetoothScan => Icons.bluetooth_searching,
      CorePermission.bluetoothConnect => Icons.bluetooth_connected,
    };
  }

  Widget icon(BuildContext context) {
    return Icon(
      iconData,
      size: 50,
      color: context.colorScheme.onPrimary,
    );
  }
}
