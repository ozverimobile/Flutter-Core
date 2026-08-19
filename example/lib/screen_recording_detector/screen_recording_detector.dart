import 'package:flutter_core/flutter_core.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const ScreenRecordingDetectorApp());
}

class ScreenRecordingDetectorApp extends StatefulWidget {
  const ScreenRecordingDetectorApp({super.key});

  @override
  State<ScreenRecordingDetectorApp> createState() => _ScreenRecordingDetectorAppState();
}

class _ScreenRecordingDetectorAppState extends State<ScreenRecordingDetectorApp> {
  // Tek yapman gereken: bu bayrağı aç/kapat. Dialog/gizleme işini paket yapar.
  bool _guardEnabled = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Uygulamayı CoreScreenRecordingGuard ile sarıyoruz. Ekran kaydı
      // algılandığında içerik otomatik gizlenip uyarı gösterilir.
      builder: (context, child) => CoreScreenRecordingGuard(
        enabled: _guardEnabled,
        child: child!,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Screen Recording Guard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Ekranı kaydetmeyi denediğinde içerik otomatik gizlenir.\n\n'
                  'Test senaryoları:\n'
                  '1. Uygulama açıkken Kontrol Merkezinden kaydı başlat.\n'
                  '2. Önce kaydı başlat, sonra uygulamayı aç.\n'
                  '3. Uygulamayı arka plana at, kaydı başlat, geri dön.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Ekran kaydı koruması'),
                value: _guardEnabled,
                onChanged: (value) => setState(() => _guardEnabled = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
