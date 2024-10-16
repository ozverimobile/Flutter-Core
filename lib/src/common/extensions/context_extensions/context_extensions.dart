import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';

/// [BuildContext] EXTENSION
extension ContextExtension on BuildContext {
  /// Equivalent to MediaQuery.sizeOf(this)
  Size get mediaQuerySize => MediaQuery.sizeOf(this);

  /// Equivalent to MediaQuery.sizeOf(this).height
  double get height => mediaQuerySize.height;

  /// Equivalent to MediaQuery.sizeOf(this).width
  double get width => mediaQuerySize.width;

  /// Gives the height of safe area on screen
  double get safeAreaHeight => height - (mediaQueryPadding.top + mediaQueryPadding.bottom);

  /// Equivalent to Theme.of(this)
  ThemeData get theme => Theme.of(this);

  /// Equivalent to Theme.of(this).brightness == Brightness.dark
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Equivalent to Theme.of(this).brightness == Brightness.light
  bool get isLightMode => theme.brightness == Brightness.light;

  /// Equivalent to Theme.of(this).textTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Equivalent to Theme.of(this).colorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Equivalent to MediaQuery.paddingOf(this)
  EdgeInsets get mediaQueryPadding => MediaQuery.paddingOf(this);

  /// Equivalent to MediaQuery.of(this)
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Equivalent to MediaQuery.viewPaddingOf(this)
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// Equivalent to MediaQuery.viewInsetsOf(this)
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Equivalent to MediaQuery.orientationOf(this)
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// Equivalent to MediaQuery.orientationOf(this) == Orientation.landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Equivalent to MediaQuery.orientationOf(this) == Orientation.portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Equivalent to MediaQuery.devicePixelRatioOf(this)
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// Equivalent to MediaQuery.textScalerOf(this)
  TextScaler get textScaler => MediaQuery.textScalerOf(this);

  /// Equivalent to Directionality.of(this)
  TextDirection get directionality => Directionality.of(this);

  /// Equivalent to DefaultTextStyle.of(this)
  DefaultTextStyle get defaultTextStyle => DefaultTextStyle.of(this);

  /// Equivalent to MediaQuery.boldTextOf(this)
  bool get usingBoldText => MediaQuery.boldTextOf(this);

  /// Equivalent to MediaQuery.sizeOf(this).shortestSide
  double get mediaQueryShortestSide => mediaQuerySize.shortestSide;

  /// Equivalent to MediaQuery.sizeOf(this).shortestSide < 600
  bool get isPhone => mediaQueryShortestSide < 600;

  /// Equivalent to MediaQuery.sizeOf(this).shortestSide >=  600 && MediaQuery.sizeOf(this).shortestSide < 1300
  bool get isTablet => mediaQueryShortestSide >= 600 && mediaQueryShortestSide < 1300;

  /// Equivalent to MediaQuery.sizeOf(this).shortestSide >= 1300
  bool get isDesktop => mediaQueryShortestSide >= 1300;

  /// Equivalent to View.of(this)
  FlutterView get flutterView => View.of(this);

  /// Equivalent to Localizations.localeOf(this)
  Locale get locale => Localizations.localeOf(this);

  /// Equivalent to Localizations.maybeLocaleOf(this)
  Locale? get maybeLocale => Localizations.maybeLocaleOf(this);

  /// Checks if keyboard is open
  bool get isKeyboardOpen => FocusManager.instance.primaryFocus?.hasFocus ?? false || flutterView.viewInsets.bottom > 0.0;

  /// Top padding of safe area
  double get topSafeAreaPadding => MediaQueryData.fromView(flutterView).padding.top;

  /// Bottom padding of safe area
  double get bottomSafeAreaPadding => MediaQueryData.fromView(flutterView).padding.bottom;

  /// Rebuilds widget with given context in the next frame
  @experimental
  void rebuildWidget() => _safeMarkNeedsBuild();

  /// Marks given element as needing to build in the next frame
  /// without throwing "setState() or markNeedsBuild() called during build" error
  ///
  /// If we are in idle or post frame callbacks phase, markNeedsBuild() will schedule a frame for rebuild
  /// If not, it will schedule a frame for rebuild after the current frame
  ///
  /// Checks also if the element is mounted
  void _safeMarkNeedsBuild() {
    final element = this as Element;
    final schedulerBinding = SchedulerBinding.instance;
    final schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.idle || schedulerPhase == SchedulerPhase.postFrameCallbacks) {
      if (element.mounted) element.markNeedsBuild();
    } else {
      schedulerBinding.addPostFrameCallback((timeStamp) {
        if (element.mounted) element.markNeedsBuild();
      });
    }
  }
}
