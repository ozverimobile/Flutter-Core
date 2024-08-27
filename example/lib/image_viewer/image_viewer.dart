import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ImageViewer(),
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
      body: Center(
        child: CoreImageViewer.network(
          images: const [
            'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
            'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__481.jpg',
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
    );
  }
}
