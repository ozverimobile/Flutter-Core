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

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final _secureImageViewerController = CoreImageController(navigatorKey: navigatorKey);
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
            child: CoreImageViewer.network(
              controller: _secureImageViewerController,
              isSecure: true,
              images: const [
                'https://picsum.photos/id/1/200/200',
                'https://picsum.photos/id/2/200/200',
                'https://picsum.photos/id/3/200/200',
                'https://picsum.photos/id/4/200/200',
                'https://picsum.photos/id/1/200/200',
                'https://picsum.photos/id/2/200/200',
                'https://picsum.photos/id/3/200/200',
                'https://picsum.photos/id/4/200/200',
                'https://picsum.photos/id/1/200/200',
                'https://picsum.photos/id/2/200/200',
                'https://picsum.photos/id/3/200/200',
                'https://picsum.photos/id/4/200/200',
              ],
              child: CoreFilledButton(
                child: const Text(
                  'Open Secure Image Viewer',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _secureImageViewerController.open();
                },
              ),
            ),
          ),
          verticalBox12,
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
          CoreFilledButton(
            onPressed: () {
              showGeneralDialog(
                context: context,
                fullscreenDialog: true,
                barrierColor: Colors.white,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return CupertinoSecureImageViewer(
                    imageUrls: const [
                      'https://picsum.photos/id/1/200/200',
                      'https://picsum.photos/id/2/200/200',
                      'https://picsum.photos/id/3/200/200',
                      'https://picsum.photos/id/4/200/200',
                      'https://picsum.photos/id/1/200/200',
                      'https://picsum.photos/id/2/200/200',
                      'https://picsum.photos/id/3/200/200',
                      'https://picsum.photos/id/4/200/200',
                      'https://picsum.photos/id/1/200/200',
                      'https://picsum.photos/id/2/200/200',
                      'https://picsum.photos/id/3/200/200',
                      'https://picsum.photos/id/4/200/200',
                    ],
                    headers: const {},
                    onClose: Navigator.of(context).pop,
                  );
                },
              );
            },
            child: const Text(
              'Open Cupertino Secure Image Viewer (iOS Only)',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
