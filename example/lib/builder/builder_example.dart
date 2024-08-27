import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return CoreBuilder(
          child: child,
        );
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CoreMaterialApp Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    CoreBuilderController.showLoader();
                    2.seconds.delay(CoreBuilderController.hideLoader);
                  },
                  child: const Text('Show Loader'),
                ),
                ElevatedButton(
                  onPressed: () {
                    2.seconds.delay<void>().loading(closeKeyboard: true);
                  },
                  child: const Text('Show Loader with Future'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
