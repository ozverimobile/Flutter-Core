import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core_example/single_child_scroll_view/single_child_scroll_view.dart';
import 'package:flutter_core_example/single_child_scroll_view/single_child_scroll_view_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'CoreSingleChildScrollView integration test',
    ($) async {
      await $.pumpWidgetAndSettle(const SingleChildScrollViewExample());

      // Butonun varlığı kontrol ediliyor
      final refreshText = $(Key(SingleChildScrollViewKeys.pullDownToRefreshText.toString()));

      // Pull up to go start yazısının mevcut olduğunu doğrula
      expect($(refreshText), findsOneWidget);

      // Refresh için kaydırma yapılıyor
      await $.tester.drag($(SingleChildScrollViewExample), const Offset(0, 100));
      await $.pump(500.milliseconds);

      // Refresh Indicator kontrol ediliyor
      expect($(Platform.isAndroid ? RefreshIndicator : CupertinoActivityIndicator), findsOneWidget);

      // String'in varlığı kontrol ediliyor
      final goStartTextKey = Key(SingleChildScrollViewKeys.pullUpToGoStart.toString());

      // List view kaydırarak pull up to go start yazısını görünür hale getir
      await $.tester.dragUntilVisible(
        $(goStartTextKey),
        $(SingleChildScrollViewExample),
        const Offset(0, -300),
      );

      await $.pump(500.milliseconds);

      // Pull up to go start yazısının mevcut olduğunu doğrula
      expect($(goStartTextKey), findsOneWidget);

      // Pull down to refresh yazısını görünür hale getir
      await $.tester.dragUntilVisible(
        $(refreshText),
        $(SingleChildScrollViewExample),
        const Offset(0, 300),
      );

      await $.pump(500.milliseconds);

      // Pull down to refresh yazısının mevcut olduğunu doğrula
      expect($(refreshText), findsOneWidget);
    },
  );
}
