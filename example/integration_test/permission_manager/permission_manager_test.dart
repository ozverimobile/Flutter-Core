import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/permission_manager/permission_manager.dart';
import 'package:flutter_core_example/permission_manager/permission_manager_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Permission Manager Integration Test',
    ($) async {
      // Uygulama çalıştırılır
      await $.pumpWidgetAndSettle(const PermissionManagerApp());

      // Notification izin butonu bul
      final notificationPermissionButtonFinder = $(Key(PermissionManagerKeys.notificationPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(notificationPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(notificationPermissionButtonFinder);

      // Devam et butonunu bul
      final continueButtonFinder = $(CoreFilledButton);

      // Butonun varlığını kontrol et
      expect($(continueButtonFinder), findsOneWidget);

      // butona tıkla
      await $.tap(continueButtonFinder);

      // İzin verilmiyor
      await $.native.denyPermission();

      // Notification izin butonu bul
      final notificationPermissionButtonFinder2 = $(Key(PermissionManagerKeys.notificationPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(notificationPermissionButtonFinder2), findsOneWidget);

      // Butona tıkla
      await $.tap(notificationPermissionButtonFinder2);

      // Dialogu kapat butonunu bul
      final closeButtonFinder = $(CoreIconButton);

      // Butonun varlığını kontrol et
      expect($(closeButtonFinder), findsOneWidget);

      // butona tıkla
      await $.tap(closeButtonFinder);

      // Notification izin butonu bul
      final notificationPermissionButtonFinder3 = $(Key(PermissionManagerKeys.notificationPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(notificationPermissionButtonFinder3), findsOneWidget);

      // Butona tıkla
      await $.tap(notificationPermissionButtonFinder3);

      // Devam et butonunu bul
      final continueButtonFinder2 = $(CoreFilledButton);

      // Butonun varlığını kontrol et
      expect($(continueButtonFinder2), findsOneWidget);

      // butona tıkla
      await $.tap(continueButtonFinder2);

      // iptal butonuna tıklanıyor
      await $('İptal').tap();

      // Butonun varlığını kontrol et
      expect($(Key(PermissionManagerKeys.notificationPermissionButtonKey.rawValue)), findsOneWidget);

      // Camera izin butonu bulunuyor.
      final cameraPermissionButtonFinder = $(Key(PermissionManagerKeys.cameraPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(cameraPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(cameraPermissionButtonFinder);

      // Devam et butonunu bul
      final continueButtonFinder3 = $(CoreFilledButton);

      // Butonun varlığını kontrol et
      expect($(continueButtonFinder3), findsOneWidget);

      // butona tıkla
      await $.tap(continueButtonFinder3);

      // İzin veriliyor
      await $.native.grantPermissionWhenInUse();

      // Butonun varlığını kontrol et
      expect($(cameraPermissionButtonFinder), findsOneWidget);

      // Fotoğraf izin butonu bulunuyor.
      final photosPermissionButtonFinder = $(Key(PermissionManagerKeys.photosPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(photosPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(photosPermissionButtonFinder);

      // Sonra hatırlat butonuna tıkla
      await $('Sonra Hatırlat').tap();

      // Status kontrolleri yapılıyor
      expect($(Key(PermissionManagerKeys.notificationPermissionStatusKey.rawValue)).text, CorePermissionStatus.permanentlyDenied.toString());
      expect($(Key(PermissionManagerKeys.cameraPermissionStatusKey.rawValue)).text, CorePermissionStatus.granted.toString());
      expect($(Key(PermissionManagerKeys.photosPermissionStatusKey.rawValue)).text, CorePermissionStatus.postponed.toString());
    },
  );
}
