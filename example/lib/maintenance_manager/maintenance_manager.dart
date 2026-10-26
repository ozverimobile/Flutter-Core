import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const MaintenanceManagerApp());
}

/// This example never talks to Firebase Remote Config. It calls
/// [CoreMaintenanceManager.showMaintenanceMode] directly with dummy
/// [MaintenanceModeInfo] instances, which is the same call `checkMaintenanceMode`
/// makes internally once it has fetched and parsed a real remote value.
///
/// [MaintenanceModeView] (shown when no `builder` is given) is the package's
/// real default screen — not a demo-only look.
class MaintenanceManagerApp extends StatelessWidget {
  const MaintenanceManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Maintenance Manager')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bu örnek Firebase Remote Config kullanmaz, doğrudan dummy '
                  'MaintenanceModeInfo verisiyle showMaintenanceMode çağrılır.\n\n'
                  'Ekran, gerçek remote config kullanımında "Tekrar Dene" ile '
                  'kapanır ya da kapanmaz (bakım hâlâ aktifse).',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                _DefaultViewStillActiveButton(),
                SizedBox(height: 12),
                _DefaultViewResolvesButton(),
                SizedBox(height: 12),
                _DefaultViewWithUrlButton(),
                SizedBox(height: 12),
                _CustomIconButton(),
                SizedBox(height: 12),
                _CustomBuilderButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _dummyTitle = 'Planlı Bakım Çalışması';
const _dummyContent = 'Uygulamamızda kısa süreli bir bakım çalışması yapılıyor. Kısa süre sonra tekrar deneyebilirsiniz.';

class _DefaultViewStillActiveButton extends StatelessWidget {
  const _DefaultViewStillActiveButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        const info = MaintenanceModeInfo(isMaintenanceModeActive: true, title: _dummyTitle, content: _dummyContent);

        CoreMaintenanceManager.instance.showMaintenanceMode(
          context: context,
          info: info,
          // Simulates a remote config re-fetch that still reports maintenance as active.
          onRetry: () => Future<void>.delayed(const Duration(seconds: 1)),
          // Called once when the screen is shown — wire this to whatever analytics/logging tool the app uses.
          onShown: (info) => debugPrint('maintenance_mode_shown: ${info.title}'),
        );
      },
      child: const Text('Varsayılan Görünüm (Bakım Devam Ediyor)'),
    );
  }
}

class _DefaultViewResolvesButton extends StatelessWidget {
  const _DefaultViewResolvesButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        const info = MaintenanceModeInfo(isMaintenanceModeActive: true, title: _dummyTitle, content: _dummyContent);

        CoreMaintenanceManager.instance.showMaintenanceMode(
          context: context,
          info: info,
          // Simulates a remote config re-fetch where maintenance has ended, so the screen closes.
          onRetry: () async {
            await Future<void>.delayed(const Duration(seconds: 1));
            if (context.mounted) Navigator.of(context).pop();
          },
        );
      },
      child: const Text('Varsayılan Görünüm (Tekrar Dene ile Kapanır)'),
    );
  }
}

class _DefaultViewWithUrlButton extends StatelessWidget {
  const _DefaultViewWithUrlButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        const info = MaintenanceModeInfo(
          isMaintenanceModeActive: true,
          title: _dummyTitle,
          content: _dummyContent,
          url: 'https://flutter.dev',
        );

        CoreMaintenanceManager.instance.showMaintenanceMode(
          context: context,
          info: info,
          // "Tekrar Dene" burada bakımı hep aktif tutar; asıl aksiyon "Daha Fazla Bilgi" ile url açmaktır.
          onRetry: () => Future<void>.delayed(const Duration(seconds: 1)),
        );
      },
      child: const Text('Varsayılan Görünüm (URL ile)'),
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  const _CustomIconButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        const info = MaintenanceModeInfo(
          isMaintenanceModeActive: true,
          title: _dummyTitle,
          content: _dummyContent,
          maintenanceIcon: 'https://cdn-icons-png.flaticon.com/512/2942/2942909.png',
        );

        CoreMaintenanceManager.instance.showMaintenanceMode(
          context: context,
          info: info,
          onRetry: () => Future<void>.delayed(const Duration(seconds: 1)),
        );
      },
      child: const Text('Varsayılan Görünüm (Özel İkon)'),
    );
  }
}

class _CustomBuilderButton extends StatelessWidget {
  const _CustomBuilderButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        const info = MaintenanceModeInfo(isMaintenanceModeActive: true, title: _dummyTitle, content: _dummyContent);

        CoreMaintenanceManager.instance.showMaintenanceMode(
          context: context,
          info: info,
          onRetry: () async {
            await Future<void>.delayed(const Duration(seconds: 1));
            if (context.mounted) Navigator.of(context).pop();
          },
          builder: (context, info, onRetry) => _CustomMaintenanceView(info: info, onRetry: onRetry),
        );
      },
      child: const Text('Projeye Özgü Tasarım (builder)'),
    );
  }
}

/// Shows how a consuming app can render its own design via the `builder`
/// parameter instead of the package's default [MaintenanceModeView].
///
/// The illustration below (stacked gradient cards) is an original composition
/// made purely from Flutter shapes — not a copy of any third-party artwork.
class _CustomMaintenanceView extends StatelessWidget {
  const _CustomMaintenanceView({required this.info, this.onRetry});

  final MaintenanceModeInfo info;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1F6B), Color(0xFF4B3FA8)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(bottom: -60, left: -60, child: _Blob(color: Color(0xFFE59EDD), size: 220)),
            const Positioned(top: -40, right: -40, child: _Blob(color: Color(0xFF6C5CE7), size: 160)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    const Spacer(),
                    const _StackedCardsIllustration(),
                    const Spacer(),
                    Text(
                      info.title ?? 'Kısa süreliğine bakımdayız.',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      info.content ?? 'En kısa sürede tekrar hizmetinizdeyiz.',
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2A1F6B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        ),
                        onPressed: onRetry,
                        child: const Text('TEKRAR DENE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A soft, blurred color blob used as background decoration.
class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.6), shape: BoxShape.circle),
      ),
    );
  }
}

/// Original abstract illustration: a diagonal stack of translucent
/// rounded gradient cards, evoking an app/device without depicting one.
class _StackedCardsIllustration extends StatelessWidget {
  const _StackedCardsIllustration();

  static const _cardColors = [
    [Color(0xFFB8A6FF), Color(0xFF7C6BEB)],
    [Color(0xFFFFC1E3), Color(0xFFE59EDD)],
    [Color(0xFFA6E3FF), Color(0xFF8FC7F2)],
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < _cardColors.length; i++)
            Positioned(
              left: i * 34.0,
              top: i * 20.0,
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  width: 110,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: _cardColors[i]),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
                  ),
                ),
              ),
            ),
          Positioned(
            right: 8,
            bottom: 0,
            child: Icon(Icons.settings_rounded, size: 40, color: Colors.white.withValues(alpha: 0.35)),
          ),
          Positioned(
            left: 0,
            bottom: 12,
            child: Icon(Icons.settings_rounded, size: 24, color: Colors.white.withValues(alpha: 0.25)),
          ),
        ],
      ),
    );
  }
}
