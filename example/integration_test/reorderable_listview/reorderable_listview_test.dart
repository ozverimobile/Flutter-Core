import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/reorderable_listview/reorderable_listview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Reorderable ListView Integration Test',
    ($) async {
      // Uygulama çalıştırılır
      await $.pumpWidgetAndSettle(const ReorderableListViewExample());

      // Integration test butonuna tıklanır
      await $('Integration Test').tap();

      // Otem 0 ile Item 1'in yeri değiştiriliyor
      final firstLocation = $.tester.getCenter($('Item 0'));
      final gesture = await $.tester.startGesture(firstLocation);
      await $.pump(1.seconds);

      final secondLocation = $.tester.getCenter($('Item 2'));
      await gesture.moveTo(secondLocation);
      await $.pump(1.seconds);

      await gesture.up();
      await $.pump(1.seconds);

      // Item 0 ve Item 1'in yerleri değişti mi kontrol ediliyor
      final item0Location = $.tester.getCenter($('Item 0'));
      final item1Location = $.tester.getCenter($('Item 1'));
      expect(item0Location.dy > item1Location.dy, true);

      // Refresh için kaydırma yapılıyor
      await $.tester.drag($(CoreReorderableListView), const Offset(0, 100));
      await $.pump(500.milliseconds);

      // Refresh Indicator kontrol ediliyor
      expect($(Platform.isAndroid ? RefreshIndicator : CupertinoActivityIndicator), findsOneWidget);
      await $.pump(1.seconds);

      // Lazy loading için kaydırma yapılıyor
      await $.tester.drag($(CoreReorderableListView), const Offset(0, -600));
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
