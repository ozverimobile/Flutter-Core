import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const image1 = 'assets/test_image_1.jpeg';
  const image2 = 'assets/test_image_2.jpeg';
  const image3 = 'assets/test_image_3.jpeg';
  final images = <String>[image1, image2, image3];
  group('Core Image Viewer', () {
    testWidgets('Opens image viewer when icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CoreImageViewer.asset(
            images: images,
            child: const Icon(Icons.image),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Closes image viewer when clear icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CoreImageViewer.asset(
            images: images,
            child: const Icon(Icons.image),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('Scrolls horizontally through images in PageView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CoreImageViewer.asset(
            images: images,
            child: const Icon(Icons.image),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();

      final pageWidth = tester.getSize(find.byType(PageView)).width;

      await tester.drag(find.byType(PageView), Offset(-pageWidth, 0));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('image_1')), findsOneWidget);

      await tester.drag(find.byType(PageView), Offset(-pageWidth, 0));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('image_2')), findsOneWidget);
    });

    testWidgets('Opens image viewer at initialIndex position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CoreImageViewer.asset(
            initialIndex: 1,
            images: images,
            child: const Icon(Icons.image),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('image_1')), findsOneWidget);
    });

    testWidgets('Closes image viewer by swiping down', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CoreImageViewer.asset(
            images: images,
            child: const Icon(Icons.image),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key('image_0')), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('Restricts scrolling while zoom is active', (WidgetTester tester) async {
      const imageKey = 'image_0';
      await tester.pumpWidget(
        MaterialApp(
          home: CoreImageViewer.asset(
            images: images,
            child: const Icon(Icons.image),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();
      final zoomX1 = await _doubleTapAndGetMatrix(tester, imageKey);
      expect(zoomX1?.getMaxScaleOnAxis(), equals(2.0));
      final zoomX2 = await _doubleTapAndGetMatrix(tester, imageKey);
      expect(zoomX2?.getMaxScaleOnAxis(), equals(3.0));
      final zoomOff = await _doubleTapAndGetMatrix(tester, imageKey);
      expect(zoomOff?.getMaxScaleOnAxis(), equals(1.0));
    });
  });

  testWidgets('Opens image viewer programmatically using controller', (WidgetTester tester) async {
    final controller = CoreImageController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: controller.open,
            child: const Icon(Icons.open_in_full),
          ),
          body: CoreImageViewer.asset(
            controller: controller,
            images: images,
            child: const Icon(Icons.image),
          ),
        ),
      ),
    );
    final button = find.widgetWithIcon(FloatingActionButton, Icons.open_in_full);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Displays error message and navigates to next image on swipe', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CoreImageViewer.asset(
          images: const ['', image1],
          child: const Icon(Icons.image),
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Error',
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.image));
    await tester.pumpAndSettle();
    expect(find.text('Error'), findsOneWidget);
    final pageWidth = tester.getSize(find.byType(PageView)).width;

    await tester.drag(find.byType(PageView), Offset(-pageWidth, 0));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('image_1')), findsOneWidget);
  });
}

Future<Matrix4?> _doubleTapAndGetMatrix(WidgetTester tester, String key) async {
  final imageFinder = find.byKey(Key(key));
  await tester.tap(imageFinder);
  await tester.pump(kDoubleTapMinTime);
  await tester.tap(imageFinder);
  await tester.pumpAndSettle();
  final interactiveViewerFinder = find.byType(InteractiveViewer);
  final interactiveViewer = tester.widget(interactiveViewerFinder) as InteractiveViewer;
  return interactiveViewer.transformationController?.value;
}
