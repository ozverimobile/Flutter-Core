import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late OverlayManager overlayManager;
  final navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    overlayManager = OverlayManager(navigatorKey: navigatorKey);
  });

  testWidgets('Toast is displayed and removed after duration', (WidgetTester tester) async {
    // Arrange: Test widget'ını oluştur
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              key: const Key('showToast'),
              child: const Text('Show Toast'),
              onPressed: () {
                overlayManager.showToast(
                  title: 'Test Toast',
                  message: 'This is a test message',
                  toastDuration: const Duration(milliseconds: 1000), // 1 saniye
                );
              },
            ),
          ),
        ),
      ),
    );

    // İlk durum: Buton Var mı?
    expect(find.text('Show Toast'), findsOneWidget);

    // showToast butonunu bul ve tıkla
    final showToast = find.byKey(const Key('showToast'));
    await tester.tap(showToast);

    // Değişiklikleri yeniden çizin
    await tester.pump();

    // Assert: Toast gösterilmeli
    expect(find.text('Test Toast'), findsOneWidget);
    expect(find.text('This is a test message'), findsOneWidget);

    // Toast'ın kaldırılmasını bekle
    await tester.pumpAndSettle(const Duration(milliseconds: 1500)); // 1.5 saniye
    expect(find.text('Test Toast'), findsNothing);
    expect(find.text('This is a test message'), findsNothing);
  });

  testWidgets('showOverlay, closeOverlay and isOverlayOpen test', (WidgetTester tester) async {
    // Arrange: Test widget'ını oluştur
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              key: const Key('showOverlay'),
              child: const Text('Show Overlay'),
              onPressed: () {
                overlayManager.showOverlay(
                  id: 'overlay-1',
                  builder: (context) {
                    return const Positioned(
                      child: Center(
                        child: Text('Test Overlay'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    // İlk durum: Buton Var mı?
    expect(find.text('Show Overlay'), findsOneWidget);

    // showOverlay butonunu bul ve tıkla
    final showOverlay = find.byKey(const Key('showOverlay'));
    await tester.tap(showOverlay);

    // Değişiklikleri yeniden çizin
    await tester.pump();

    // Assert: Toast gösterilmeli
    expect(find.text('Test Overlay'), findsOneWidget);
    expect(overlayManager.isOverlayOpen(id: 'overlay-1'), true);

    // closeOverlay
    overlayManager.closeOverlay(id: 'overlay-1');
    await tester.pump();

    // Assert: Toast gitmiş olmalı
    expect(find.text('Test Overlay'), findsNothing);
    expect(overlayManager.isOverlayOpen(id: 'overlay-1'), false);
  });

  testWidgets('closeAllToasts test', (WidgetTester tester) async {
    // Arrange: Test widget'ını oluştur
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Center(
            child: Column(
              children: [
                ElevatedButton(
                  key: const Key('showToast1'),
                  child: const Text('Show Toast 1'),
                  onPressed: () {
                    overlayManager.showToast(
                      title: 'Test Toast',
                      message: 'This is a test message',
                    );
                  },
                ),
                ElevatedButton(
                  key: const Key('showToast2'),
                  child: const Text('Show Toast 2'),
                  onPressed: () {
                    overlayManager.showToast(
                      title: 'Test Toast 2',
                      message: 'This is a test message 2',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // İlk durum: Buton Var mı?
    expect(find.text('Show Toast 1'), findsOneWidget);
    expect(find.text('Show Toast 2'), findsOneWidget);

    // showToast butonunu bul ve tıkla
    final showToast1 = find.byKey(const Key('showToast1'));
    final showToast2 = find.byKey(const Key('showToast2'));
    await tester.tap(showToast1);
    await tester.tap(showToast2);

    // Değişiklikleri yeniden çizin
    await tester.pump();

    // Assert: Toast gösterilmeli
    expect(find.text('Test Toast'), findsOneWidget);
    expect(find.text('This is a test message'), findsOneWidget);

    // Assert: Toast gösterilmeli
    expect(find.text('Test Toast 2'), findsOneWidget);
    expect(find.text('This is a test message 2'), findsOneWidget);

    // Toast'ların kaldırılmasını bekle
    overlayManager.closeAllToasts(immediate: true);

    // Değişiklikleri yeniden çizin
    await tester.pump();

    // Assert: Toast gösterilmemeli
    expect(find.text('Test Toast'), findsNothing);
    expect(find.text('This is a test message'), findsNothing);

    // Assert: Toast gösterilmeli
    expect(find.text('Test Toast 2'), findsNothing);
    expect(find.text('This is a test message 2'), findsNothing);

    await tester.pumpAndSettle(3.seconds);
  });

  testWidgets('closeLatestOverlay and closeAllOverlays test', (WidgetTester tester) async {
    // Arrange: Test widget'ını oluştur
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Center(
            child: Column(
              children: [
                ElevatedButton(
                  key: const Key('showOverlay1'),
                  child: const Text('Show Overlay 1'),
                  onPressed: () {
                    overlayManager.showOverlay(
                      id: 'overlay-1',
                      builder: (context) => Positioned(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.red,
                          child: const Center(child: Text('Overlay 1')),
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  key: const Key('showOverlay2'),
                  child: const Text('Show Overlay 2'),
                  onPressed: () {
                    overlayManager.showOverlay(
                      id: 'overlay-2',
                      builder: (context) => Positioned(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.red,
                          child: const Center(child: Text('Overlay 2')),
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  key: const Key('showOverlay3'),
                  child: const Text('Show Overlay 3'),
                  onPressed: () {
                    overlayManager.showOverlay(
                      id: 'overlay-3',
                      builder: (context) => Positioned(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.red,
                          child: const Center(child: Text('Overlay 3')),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // İlk durum: Buton Var mı?
    expect(find.text('Show Overlay 1'), findsOneWidget);
    expect(find.text('Show Overlay 2'), findsOneWidget);
    expect(find.text('Show Overlay 3'), findsOneWidget);

    // showToast butonunu bul ve tıkla
    final showOverlay1 = find.byKey(const Key('showOverlay1'));
    final showOverlay2 = find.byKey(const Key('showOverlay2'));
    final showOverlay3 = find.byKey(const Key('showOverlay3'));
    await tester.tap(showOverlay1);
    await tester.tap(showOverlay2);
    await tester.tap(showOverlay3);

    // Değişiklikleri yeniden çizin
    await tester.pump();

    // Assert: overlay gösterilmeli
    expect(find.text('Overlay 1'), findsOneWidget);
    expect(find.text('Overlay 2'), findsOneWidget);
    expect(find.text('Overlay 3'), findsOneWidget);

    overlayManager.closeLatestOverlay();

    await tester.pump();

    expect(find.text('Overlay 1'), findsOneWidget);
    expect(find.text('Overlay 2'), findsOneWidget);
    expect(find.text('Overlay 3'), findsNothing);

    overlayManager.closeAllOverlays();

    await tester.pump();

    expect(find.text('Overlay 1'), findsNothing);
    expect(find.text('Overlay 2'), findsNothing);
    expect(find.text('Overlay 3'), findsNothing);
  });
}
