import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Picker Tests',
    () {
      final navigatorKey = GlobalKey<NavigatorState>();
      final popupManager = PopupManager(navigatorKey: navigatorKey);

      testWidgets('Show Adaptive Date Picker Test', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.showAdaptiveDatePicker(
            initialDateTime: DateTime.now(),
            minimumDate: DateTime.now().subtract(const Duration(days: 365)),
            maximumDate: DateTime.now().add(const Duration(days: 365)),
          ),
        );
        await tester.pump();
        expect(find.byType(DatePickerDialog), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.byType(DatePickerDialog), findsNothing);
        final id = UniqueKey().toString();
        unawaited(
          popupManager.showAdaptiveDatePicker(
            initialDateTime: DateTime.now(),
            minimumDate: DateTime.now().subtract(const Duration(days: 365)),
            maximumDate: DateTime.now().add(const Duration(days: 365)),
            id: id,
          ),
        );
        await tester.pump();
        expect(find.byType(DatePickerDialog), findsOneWidget);
        popupManager.hidePopup<void>(id: id);
        await tester.pump();
        expect(find.byType(DatePickerDialog), findsNothing);
      });

      testWidgets('Show Adaptive Picker Test', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.showAdaptivePicker(
            children: const [
              Text('Item 1'),
              Text('Item 2'),
              Text('Item 3'),
            ],
          ),
        );
        await tester.pump();
        expect(find.text('Item 1'), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.text('Item 1'), findsNothing);
      });

      testWidgets('Image Source Picker Test', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.showImageSourcePicker(),
        );
        await tester.pump();
        expect(find.text('Galeriden Seç'), findsOneWidget);
        expect(find.text('Kameradan Çek'), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.text('Galeriden Seç'), findsNothing);
        expect(find.text('Kameradan Çek'), findsNothing);
      });
    },
  );

  group(
    'Search Sheet Tests',
    () {
      final navigatorKey = GlobalKey<NavigatorState>();
      final popupManager = PopupManager(navigatorKey: navigatorKey);
      testWidgets('Single Selectable Search Sheet Test', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.singleSelectableSearchSheet(
            items: [
              _SearchOption(title: 'Item 1', subtitle: 'Subtitle 1'),
              _SearchOption(title: 'Item 2', subtitle: 'Subtitle 2'),
            ],
          ),
        );
        await tester.pump();
        expect(find.text('Item 1'), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.text('Item 1'), findsNothing);
      });

      testWidgets('Multi Selectable Search Sheet Test', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.multiSelectableSearchSheet(
            items: [
              _SearchOption(title: 'Item 1', subtitle: 'Subtitle 1'),
              _SearchOption(title: 'Item 2', subtitle: 'Subtitle 2'),
            ],
          ),
        );
        await tester.pump();
        expect(find.text('Item 1'), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.text('Item 1'), findsNothing);
      });
    },
  );
  group(
    'Dialog Tests',
    () {
      final navigatorKey = GlobalKey<NavigatorState>();
      final popupManager = PopupManager(navigatorKey: navigatorKey);

      testWidgets(
        'Dialog Test',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              navigatorKey: navigatorKey,
              home: const Scaffold(
                body: Center(),
              ),
            ),
          );

          unawaited(
            popupManager.showDialog(
              builder: (context) => const AlertDialog(
                title: Text('Title'),
                content: Text('Content'),
              ),
            ),
          );
          await tester.pump();
          expect(find.text('Title'), findsOneWidget);
          expect(find.text('Content'), findsOneWidget);
          popupManager.hidePopup<void>();
          await tester.pump();
          expect(find.text('Title'), findsNothing);
          expect(find.text('Content'), findsNothing);
          final id = UniqueKey().toString();
          unawaited(
            popupManager.showDialog(
              builder: (context) => const AlertDialog(
                title: Text('Title'),
                content: Text('Content'),
              ),
              id: id,
            ),
          );
          await tester.pump();
          expect(find.text('Title'), findsOneWidget);
          expect(find.text('Content'), findsOneWidget);
          popupManager.hidePopup<void>(id: id);
          await tester.pump();
          expect(find.text('Title'), findsNothing);
          expect(find.text('Content'), findsNothing);
        },
      );
      testWidgets(
        'Cupertino Dialog Test',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              navigatorKey: navigatorKey,
              home: const Scaffold(
                body: Center(),
              ),
            ),
          );

          unawaited(
            popupManager.showCupertinoDialog(
              builder: (context) => const CupertinoAlertDialog(
                title: Text('Title'),
                content: Text('Content'),
              ),
            ),
          );
          await tester.pump();
          expect(find.text('Title'), findsOneWidget);
          expect(find.text('Content'), findsOneWidget);
          popupManager.hidePopup<void>();
          await tester.pump();
          expect(find.text('Title'), findsNothing);
          expect(find.text('Content'), findsNothing);
          final id = UniqueKey().toString();
          unawaited(
            popupManager.showCupertinoDialog(
              builder: (context) => const CupertinoAlertDialog(
                title: Text('Title'),
                content: Text('Content'),
              ),
              id: id,
            ),
          );
          await tester.pump();
          expect(find.text('Title'), findsOneWidget);
          expect(find.text('Content'), findsOneWidget);
          popupManager.hidePopup<void>(id: id);
          await tester.pump();
          expect(find.text('Title'), findsNothing);
          expect(find.text('Content'), findsNothing);
        },
      );
      testWidgets(
        'Adaptive Info Dialog Test',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              navigatorKey: navigatorKey,
              home: const Scaffold(
                body: Center(),
              ),
            ),
          );

          unawaited(
            popupManager.showAdaptiveInfoDialog(
              title: const Text('Title'),
              content: const Text('Content'),
            ),
          );
          await tester.pump();
          expect(find.text('Title'), findsOneWidget);
          expect(find.text('Content'), findsOneWidget);
          popupManager.hidePopup<void>();
          await tester.pump();
          expect(find.text('Title'), findsNothing);
          expect(find.text('Content'), findsNothing);
          final id = UniqueKey().toString();
          unawaited(
            popupManager.showAdaptiveInfoDialog(
              title: const Text('Title'),
              content: const Text('Content'),
              id: id,
            ),
          );
          await tester.pump();
          expect(find.text('Title'), findsOneWidget);
          expect(find.text('Content'), findsOneWidget);
          popupManager.hidePopup<void>(id: id);
          await tester.pump();
          expect(find.text('Title'), findsNothing);
          expect(find.text('Content'), findsNothing);
        },
      );

      testWidgets('Default Adaptive Alert Dialog Test', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.showDefaultAdaptiveAlertDialog(
            title: const Text('Title'),
            content: const Text('Content'),
          ),
        );
        await tester.pump();
        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.text('Title'), findsNothing);
        expect(find.text('Content'), findsNothing);
        expect(find.text('OK'), findsNothing);
        final id = UniqueKey().toString();
        unawaited(
          popupManager.showDefaultAdaptiveAlertDialog(
            title: const Text('Title'),
            content: const Text('Content'),
            id: id,
          ),
        );
        await tester.pump();
        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
        popupManager.hidePopup<void>(id: id);
        await tester.pump();
        expect(find.text('Title'), findsNothing);
        expect(find.text('Content'), findsNothing);
        expect(find.text('OK'), findsNothing);
      });
      testWidgets(
        'Update Available Dialog',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              navigatorKey: navigatorKey,
              home: const Scaffold(
                body: Center(),
              ),
            ),
          );

          unawaited(
            popupManager.showUpdateAvailableDialog(),
          );
          await tester.pump();
          expect(find.text('Güncelle'), findsOneWidget);
          expect(find.text('Daha sonra'), findsOneWidget);
          expect(find.text('Güncelleme Mevcut'), findsOneWidget);
          expect(find.text('Uygulamanın yeni sürümü mevcut. Güncellemek ister misiniz?'), findsOneWidget);
          popupManager.hidePopup<void>();
          await tester.pump();
          expect(find.text('Güncelle'), findsNothing);
          expect(find.text('Daha sonra'), findsNothing);
          expect(find.text('Güncelleme Mevcut'), findsNothing);
          expect(find.text('Uygulamanın yeni sürümü mevcut. Güncellemek ister misiniz?'), findsNothing);
        },
      );

      testWidgets('Adaptive Input Dialog Test', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.showAdaptiveInputDialog(
            title: 'Title',
          ),
        );
        await tester.pump();
        expect(find.text('Title'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.text('Title'), findsNothing);
        expect(find.byType(TextField), findsNothing);
      });
    },
  );

  group('General Tests', () {
    final navigatorKey = GlobalKey<NavigatorState>();
    final popupManager = PopupManager(navigatorKey: navigatorKey);
    testWidgets(
      'Loader Test',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        popupManager.showLoader();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        final id = UniqueKey().toString();
        popupManager.showLoader(id: id);
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        popupManager.hidePopup<void>(id: id);
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'ModalBottomSheet Test',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.showModalBottomSheet(
            builder: (context) => const SizedBox(),
          ),
        );
        await tester.pump();
        expect(find.byType(SizedBox), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.byType(SizedBox), findsNothing);
        final id = UniqueKey().toString();
        unawaited(
          popupManager.showModalBottomSheet(
            builder: (context) => const SizedBox(),
            id: id,
          ),
        );
        await tester.pump();
        expect(find.byType(SizedBox), findsOneWidget);
        popupManager.hidePopup<void>(id: id);
        await tester.pump();
        expect(find.byType(SizedBox), findsNothing);
      },
    );

    testWidgets(
      'Cupertino Modal Popup Test',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        unawaited(
          popupManager.showCupertinoModalPopup(
            builder: (context) => const SizedBox(),
          ),
        );
        await tester.pump();
        expect(find.byType(SizedBox), findsOneWidget);
        popupManager.hidePopup<void>();
        await tester.pump();
        expect(find.byType(SizedBox), findsNothing);
        final id = UniqueKey().toString();
        unawaited(
          popupManager.showCupertinoModalPopup(
            builder: (context) => const SizedBox(),
            id: id,
          ),
        );
        await tester.pump();
        expect(find.byType(SizedBox), findsOneWidget);
        popupManager.hidePopup<void>(id: id);
        await tester.pump();
        expect(find.byType(SizedBox), findsNothing);
      },
    );

    testWidgets(
      'Is Popup Open Test',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(
              body: Center(),
            ),
          ),
        );

        final id = UniqueKey().toString();
        expect(popupManager.isPopupOpen(id: id), false);
        popupManager.showLoader(id: id);
        await tester.pump();
        expect(popupManager.isPopupOpen(id: id), true);
        popupManager.hidePopup<void>(id: id);
        await tester.pump();
        expect(popupManager.isPopupOpen(id: id), false);
      },
    );

    testWidgets('Hide All Popups Test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(
            body: Center(),
          ),
        ),
      );

      popupManager.showLoader();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      popupManager.showLoader(id: 'id');
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      popupManager.showLoader(id: 'id2');
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      popupManager.hideAllPopups();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Hide Popup Between Others Test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(
            body: Center(),
          ),
        ),
      );

      popupManager.showLoader(id: 'id');
      await tester.pump();
      popupManager.showLoader(id: 'id1');
      await tester.pump();
      popupManager.showLoader(id: 'id2');
      await tester.pump();

      expect(popupManager.isPopupOpen(id: 'id') && popupManager.isPopupOpen(id: 'id1') && popupManager.isPopupOpen(id: 'id2'), true);
      popupManager.hidePopup<void>(id: 'id1');
      await tester.pump();
      expect(popupManager.isPopupOpen(id: 'id') && !popupManager.isPopupOpen(id: 'id1') && popupManager.isPopupOpen(id: 'id2'), true);
    });

    testWidgets('Adaptive Action Sheet Test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(
            body: Center(),
          ),
        ),
      );

      unawaited(
        popupManager.showAdaptiveActionSheet(
          actions: [
            AdaptiveAction(
              label: 'Action 1',
              onPressed: () {},
            ),
          ],
        ),
      );
      await tester.pump();
      expect(find.text('Action 1'), findsOneWidget);
      popupManager.hidePopup<void>();
      await tester.pump();
      expect(find.text('Action 1'), findsNothing);
    });
  });
}

class _SearchOption with SelectableSearchMixin {
  _SearchOption({required this.title, required this.subtitle});

  @override
  bool get active => true;

  @override
  bool filter(String query) => true;

  @override
  final String subtitle;

  @override
  final String title;
}
