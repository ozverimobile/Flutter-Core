import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class CoreResponsiveLayout extends StatelessWidget {
  CoreResponsiveLayout({
    this.phone,
    this.tablet,
    this.desktop,
    super.key,
  })  : assert(!(DeviceType.isPhone() && phone == null), 'Phone layout is required'),
        assert(!(DeviceType.isTablet() && tablet == null), 'Tablet layout is required'),
        assert(!(DeviceType.isDesktop() && desktop == null), 'Desktop layout is required');

  final WidgetBuilder? phone;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return switch (DeviceType.deviceType) {
      DeviceType.phone => phone!(context),
      DeviceType.tablet => tablet!(context),
      DeviceType.desktop => desktop!(context),
    };
  }
}
