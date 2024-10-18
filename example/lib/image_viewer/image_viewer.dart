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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CoreImageViewer.network(
              controller: _imageController,
              images: const [
                'https://img.freepik.com/free-vector/gradient-pink-green-background_52683-110638.jpg?t=st=1729075631~exp=1729079231~hmac=9c0c410c41d56d2da4135d8c568cdb8f055ae57f48d0f213c2ab7bec4c05c1d0&w=1800',
                'https://img.freepik.com/premium-vector/3d-summer-yellow-scene-background_317810-4653.jpg?w=2000',
              ],
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
