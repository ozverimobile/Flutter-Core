import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

typedef MaintenanceModeBuilder = Widget Function(
  BuildContext context,
  MaintenanceModeInfo info,
  Future<void> Function()? onRetry,
);

abstract interface class ICoreMaintenanceManager {
  Future<void> checkMaintenanceMode({
    required BuildContext context,
    required FirebaseRemoteConfig remoteConfigInstance,
    String? currentUserId,
    MaintenanceModeBuilder? builder,
    void Function(MaintenanceModeInfo info)? onShown,
  });

  Future<void> showMaintenanceMode({
    required BuildContext context,
    required MaintenanceModeInfo info,
    MaintenanceModeBuilder? builder,
    Future<void> Function()? onRetry,
    void Function(MaintenanceModeInfo info)? onShown,
  });
}

/// Checks a Firebase Remote Config value (key: `maintenance_mode`) and, when active,
/// blocks the app with a non-dismissible full screen dialog.
///
/// Independent from `Core.initialize` — does nothing unless [checkMaintenanceMode] is called,
/// and fails silently (does nothing) when Firebase/Remote Config is unavailable or misconfigured.
class CoreMaintenanceManager implements ICoreMaintenanceManager {
  CoreMaintenanceManager._();

  static final instance = CoreMaintenanceManager._();

  static const _remoteConfigKey = 'maintenance_mode';

  @override
  Future<void> checkMaintenanceMode({
    required BuildContext context,
    required FirebaseRemoteConfig remoteConfigInstance,
    String? currentUserId,
    MaintenanceModeBuilder? builder,
    void Function(MaintenanceModeInfo info)? onShown,
  }) async {
    try {
      final info = await _fetchMaintenanceInfo(remoteConfigInstance: remoteConfigInstance, currentUserId: currentUserId);
      if (info == null) return;

      if (!context.mounted) return;

      await showMaintenanceMode(
        context: context,
        info: info,
        builder: builder,
        onShown: onShown,
        onRetry: () async {
          final latestInfo = await _fetchMaintenanceInfo(remoteConfigInstance: remoteConfigInstance, currentUserId: currentUserId);
          if (latestInfo == null && context.mounted) Navigator.of(context).pop();
        },
      );
    } catch (e) {
      CoreLogger.log(e, color: LogColors.red);
    }
  }

  /// Fetches and parses the remote maintenance mode value.
  ///
  /// Returns `null` when maintenance mode should not be shown (inactive, not
  /// targeted at [currentUserId], or the fetch/parse failed).
  Future<MaintenanceModeInfo?> _fetchMaintenanceInfo({
    required FirebaseRemoteConfig remoteConfigInstance,
    String? currentUserId,
  }) async {
    final isSuccess = await remoteConfigInstance.fetchAndActivate();
    if (!isSuccess) return null;

    final rawValue = remoteConfigInstance.getString(_remoteConfigKey);
    if (rawValue.isEmpty) return null;

    final decoded = jsonDecode(rawValue);
    if (decoded is! Map<String, dynamic>) return null;

    final info = MaintenanceModeInfo.fromJson(decoded);
    if (info.isMaintenanceModeActive != true) return null;

    final userIds = info.userIds;
    if (!userIds.isNullOrEmpty && !userIds!.contains(currentUserId)) return null;

    return info;
  }

  @override
  Future<void> showMaintenanceMode({
    required BuildContext context,
    required MaintenanceModeInfo info,
    MaintenanceModeBuilder? builder,
    Future<void> Function()? onRetry,
    void Function(MaintenanceModeInfo info)? onShown,
  }) {
    onShown?.call(info);
    return showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black,
      transitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => PopScope(
        canPop: false,
        child: builder?.call(context, info, onRetry) ?? MaintenanceModeView(info: info, onRetry: onRetry),
      ),
    );
  }
}

/// Default full screen maintenance view. Shown when `checkMaintenanceMode` /
/// `showMaintenanceMode` is called without a custom `builder`.
class MaintenanceModeView extends StatelessWidget {
  const MaintenanceModeView({required this.info, this.onRetry, super.key});

  final MaintenanceModeInfo info;

  /// Called when the user taps "Tekrar Dene". When it completes without
  /// closing this screen, maintenance mode is still active.
  final Future<void> Function()? onRetry;

  static const _defaultTitle = 'Kısa süreliğine bakımdayız';
  static const _defaultContent = 'Uygulamamız şu anda bakım çalışması nedeniyle hizmet verememektedir. Lütfen daha sonra tekrar deneyiniz.';
  static const _illustrationAsset = 'assets/maintenance/maintenance_illustration.png';

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final illustrationWidth = context.width * 0.72;

    return Material(
      child: ColoredBox(
        color: context.theme.scaffoldBackgroundColor,
        child: Stack(
          children: [
            Positioned(bottom: -60, left: -60, child: _MaintenanceBlob(color: colorScheme.tertiary, size: 220)),
            Positioned(top: -40, right: -40, child: _MaintenanceBlob(color: colorScheme.secondary, size: 160)),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Fixed illustration — never scrolls.
                      Align(
                        alignment: const Alignment(0, -0.35),
                        child: _MaintenanceIllustration(iconUrl: info.maintenanceIcon, width: illustrationWidth),
                      ),
                      // Bottom-anchored text block, positioned to overlap the lower part of
                      // the illustration; scrolls independently (and only) when it overflows.
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        top: constraints.maxHeight * 0.45,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                          child: LayoutBuilder(
                            builder: (context, textConstraints) => SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: textConstraints.maxHeight),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      info.title ?? MaintenanceModeView._defaultTitle,
                                      style: TextStyle(color: colorScheme.onSurface, fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      info.content ?? MaintenanceModeView._defaultContent,
                                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (!info.url.isNullOrEmpty) ...[
                                      const SizedBox(height: 32),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CoreFilledButton.autoIndicator(
                                          backgroundColor: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(32),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          indicatorStyle: IndicatorStyle(color: colorScheme.onPrimary),
                                          onPressed: () => CoreUrlLauncher.instance.launchWebUrl(url: info.url!),
                                          child: Text(
                                            'DAHA FAZLA BİLGİ',
                                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: colorScheme.onPrimary),
                                          ),
                                        ),
                                      ),
                                      if (onRetry != null)
                                        CoreTextButton.autoIndicator(
                                          indicatorStyle: IndicatorStyle(color: colorScheme.primary),
                                          onPressed: onRetry,
                                          child: Text('Tekrar Dene', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                                        ),
                                    ] else if (onRetry != null) ...[
                                      const SizedBox(height: 32),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CoreFilledButton.autoIndicator(
                                          backgroundColor: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(32),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          indicatorStyle: IndicatorStyle(color: colorScheme.onPrimary),
                                          onPressed: onRetry,
                                          child: Text(
                                            'TEKRAR DENE',
                                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: colorScheme.onPrimary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceIllustration extends StatelessWidget {
  const _MaintenanceIllustration({required this.iconUrl, required this.width});

  final String? iconUrl;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (!iconUrl.isNullOrEmpty) {
      return Image.network(iconUrl!, width: width, errorBuilder: (context, error, stackTrace) => _BundledIllustration(width: width));
    }
    return _BundledIllustration(width: width);
  }
}

class _BundledIllustration extends StatelessWidget {
  const _BundledIllustration({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      MaintenanceModeView._illustrationAsset,
      package: 'flutter_core',
      width: width,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.build_rounded, size: width * 0.4, color: context.colorScheme.onSurfaceVariant),
    );
  }
}

/// A soft, blurred color blob used as background decoration.
class _MaintenanceBlob extends StatelessWidget {
  const _MaintenanceBlob({required this.color, required this.size});

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
