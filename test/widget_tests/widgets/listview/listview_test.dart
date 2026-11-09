import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoreListView onReachedEnd', () {
    Widget buildList({required ScrollController controller, required FutureOr<void> Function() onReachedEnd}) {
      return MaterialApp(
        home: Scaffold(
          body: CoreListView.builder(
            controller: controller,
            itemCount: 50,
            itemExtent: 50,
            onReachedEnd: onReachedEnd,
            itemBuilder: (_, index) => Text('item $index'),
          ),
        ),
      );
    }

    testWidgets('does not call setState after dispose when onReachedEnd completes late', (tester) async {
      final completer = Completer<void>();
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildList(controller: controller, onReachedEnd: () => completer.future));
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();

      // The user leaves the screen while the request is still in flight.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      completer.complete();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
