import 'package:flutter_core/flutter_core.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(
    const MaterialApp(
      home: AndroidSSProtection(),
    ),
  );
}

class AndroidSSProtection extends StatefulWidget {
  const AndroidSSProtection({super.key});

  @override
  State<AndroidSSProtection> createState() => _AndroidSSProtectionState();
}

class _AndroidSSProtectionState extends State<AndroidSSProtection> {
  @override
  void initState() {
    super.initState();
    AndroidScreenshotBlocker.setEnabled(true);
  }

  @override
  void dispose() {
    super.dispose();
    AndroidScreenshotBlocker.setEnabled(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          color: Colors.red,
        ),
      ),
    );
  }
}
