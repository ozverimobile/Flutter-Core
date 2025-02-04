import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/listview/listview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'ListView Integration Test',
    ($) async {
      // Uygulama çalıştırılır
      await $.pumpWidgetAndSettle(const ListViewExample());

      // Integration test butonuna tıklanır
      await $('Integration Test').tap();

      // Refresh için kaydırma yapılıyor
      await $.tester.drag($(CoreListView), const Offset(0, 100));
      await $.pump(500.milliseconds);

      // Refresh Indicator kontrol ediliyor
      expect($(Platform.isAndroid ? RefreshIndicator : CupertinoActivityIndicator), findsOneWidget);
      await $.pump(1.seconds);

      // Lazy loading için kaydırma yapılıyor
      await $.tester.drag($(CoreListView), const Offset(0, -600));
      await $.pump(500.milliseconds);

      // Refresh Indicator kontrol ediliyor
      expect($(Platform.isAndroid ? RefreshIndicator : CupertinoActivityIndicator), findsOneWidget);
      await $.pump(1.seconds);

      // 20. item kontrol ediliyor.
      expect($('Item 20'), findsOneWidget);

      // Uygulama bekletiliyor.
      await $.pump(2.seconds);
    },
  );
}
