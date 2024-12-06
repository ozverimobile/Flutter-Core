import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final _imageController = CoreImageController(navigatorKey: navigatorKey);

void main() {
  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      home: const ImageViewer(),
    ),
  );
}

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key});

  @override
  Widget build(BuildContext context) {
    const image1 = '../assets/test_image_1.jpeg';
    const image2 = '../assets/test_image_2.jpeg';
    const image3 = '../assets/test_image_3.jpeg';
    final images = <String>[image1, image2, image3];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CoreImageViewer.asset(
              controller: _imageController,
              images: images,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Error',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 50,
                color: Colors.blue,
              ),
            ),
          ),
          CoreTextButton(
            onPressed: () async {
              _imageController.open();
              await Future<void>.delayed(3.seconds);
              _imageController.close();
            },
            child: const Text('Programmatically Open'),
          ),
        ],
      ),
    );
  }
}
