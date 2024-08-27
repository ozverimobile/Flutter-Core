import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class CoreBuilder extends StatefulWidget {
  const CoreBuilder({
    required this.child,
    this.indicator,
    super.key,
  });

  final Widget? child;
  final Widget? indicator;

  static bool _usesCoreBuilder = false;

  static bool get usesCoreBuilder => _usesCoreBuilder;

  @override
  State<CoreBuilder> createState() => _CoreBuilderState();
}

class _CoreBuilderState extends State<CoreBuilder> {
  @override
  void initState() {
    CoreBuilder._usesCoreBuilder = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _CoreKeyboardHandler(child: widget.child),
        _CoreProgressIndicator(indicator: widget.indicator),
      ],
    );
  }
}

class _CoreKeyboardHandler extends StatelessWidget {
  const _CoreKeyboardHandler({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Core.closeKeyboard,
      child: child,
    );
  }
}

class _CoreProgressIndicator extends StatelessWidget {
  const _CoreProgressIndicator({this.indicator});

  final Widget? indicator;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: CoreBuilderController.isShowLoadingNotifier,
      builder: (context, isShowLoading, child) {
        if (isShowLoading) return indicator ?? const _Indicator();
        return emptyBox;
      },
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: const ColoredBox(
          color: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}
