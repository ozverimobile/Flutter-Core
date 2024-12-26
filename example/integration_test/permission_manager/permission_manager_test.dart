import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/permission_manager/permission_manager.dart';
import 'package:flutter_core_example/permission_manager/permission_manager_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'counter state is the same after going to home and switching apps',
    ($) async {
      // Uygulama çalıştırılır
      await $.pumpWidgetAndSettle(const PermissionManagerApp());

      // Notification izin butonu bul
      final notificationPermissionButtonFinder = find.byKey(Key(PermissionManagerKeys.notificationPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(notificationPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(notificationPermissionButtonFinder);

      // Devam et butonunu bul
      final continueButtonFinder = find.byWidgetPredicate((widget) => widget is CoreFilledButton);

      // Butonun varlığını kontrol et
      expect($(continueButtonFinder), findsOneWidget);

      // butona tıkla
      await $.tap(continueButtonFinder);

      // İzin verilmiyor
      await $.native.denyPermission();

      // Butonun varlığını kontrol et
      expect($(notificationPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(notificationPermissionButtonFinder);

      // Dialogu kapat butonunu bul
      final closeButtonFinder = find.byType(CoreIconButton);

      // Butonun varlığını kontrol et
      expect($(closeButtonFinder), findsOneWidget);

      // butona tıkla
      await $.tap(closeButtonFinder);

      // Butonun varlığını kontrol et
      expect($(notificationPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(notificationPermissionButtonFinder);

      // Devam et butonunu bul
      final continueButtonFinder2 = find.byWidgetPredicate((widget) => widget is CoreFilledButton);

      // Butonun varlığını kontrol et
      expect($(continueButtonFinder2), findsOneWidget);

      // butona tıkla
      await $.tap(continueButtonFinder2);

      // iptal butonuna tıklanıyor
      await $('İptal').tap();

      // Butonun varlığını kontrol et
      expect($(notificationPermissionButtonFinder), findsOneWidget);

      // Camera izin butonu bulunuyor.
      final cameraPermissionButtonFinder = find.byKey(Key(PermissionManagerKeys.cameraPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(cameraPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(cameraPermissionButtonFinder);

      // Devam et butonunu bul
      final continueButtonFinder3 = find.byWidgetPredicate((widget) => widget is CoreFilledButton);

      // Butonun varlığını kontrol et
      expect($(continueButtonFinder3), findsOneWidget);

      // butona tıkla
      await $.tap(continueButtonFinder3);

      // İzin veriliyor
      await $.native.grantPermissionWhenInUse();

      // Butonun varlığını kontrol et
      expect($(cameraPermissionButtonFinder), findsOneWidget);

      // Fotoğraf izin butonu bulunuyor.
      final photosPermissionButtonFinder = find.byKey(Key(PermissionManagerKeys.photosPermissionButtonKey.rawValue));

      // Butonun varlığını kontrol et
      expect($(photosPermissionButtonFinder), findsOneWidget);

      // Butona tıkla
      await $.tap(photosPermissionButtonFinder);

      // Sonra hatırlat butonuna tıkla
      await $('Sonra Hatırlat').tap();

      // Status kontrolleri yapılıyor
      expect($(find.byKey(Key(PermissionManagerKeys.notificationPermissionStatusKey.rawValue))).text, CorePermissionStatus.permanentlyDenied.toString());
      expect($(find.byKey(Key(PermissionManagerKeys.cameraPermissionStatusKey.rawValue))).text, CorePermissionStatus.granted.toString());
      expect($(find.byKey(Key(PermissionManagerKeys.photosPermissionStatusKey.rawValue))).text, CorePermissionStatus.postponed.toString());
    },
  );
}
