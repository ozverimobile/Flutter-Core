import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const CoreTextExample());
}

class CoreTextExample extends StatelessWidget {
  const CoreTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CoreAutoSizeText(
                'A long long text' * 10,
                minFontSize: 8,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              verticalBox20,
              CoreAutoSizeText.rich(
                TextSpan(
                  text: 'A long long text' * 10,
                  children: [
                    TextSpan(
                      text: 'A long long text' * 10,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              verticalBox24,
              const SizedBox(
                width: 170,
                height: 100,
                child: CoreAutoSizeText(
                  'A looonnnngggtext1123tttttttttt qweqeqqwe12313123qwe',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
