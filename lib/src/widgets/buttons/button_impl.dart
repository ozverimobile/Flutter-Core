import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
class CoreButton extends StatefulWidget {
  const CoreButton({
    required this.child,
    required this.onPressed,
    super.key,
  })  : _autoIndicator = false,
        _indicatorStyle = null;

  const CoreButton.autoIndicator({
    required this.child,
    required this.onPressed,
    super.key,
    IndicatorStyle? indicatorStyle,
  })  : _autoIndicator = true,
        _indicatorStyle = indicatorStyle;

  final FutureOr<dynamic> Function()? onPressed;

  final Widget child;
  final bool _autoIndicator;
  final IndicatorStyle? _indicatorStyle;

  @override
  State<CoreButton> createState() => _CoreButtonState();
}

class _CoreButtonState extends State<CoreButton> {
  var _isProcessing = false;

  Future<void> _onPressedCallback() async {
    if (widget.onPressed == null) return;
    if (!widget._autoIndicator) return await widget.onPressed!.call();
    setState(() => _isProcessing = true);
    final overlayEntry = OverlayEntry(builder: (context) => const Positioned.fill(child: AbsorbPointer()));
    Overlay.of(context).insert(overlayEntry);
    try {
      await widget.onPressed!.call();
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: _onPressedCallback,
            icon: !_isProcessing
                ? widget.child
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                        height: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                        child: CircularProgressIndicator(
                          color: widget._indicatorStyle?.color ?? context.theme.colorScheme.onPrimary,
                          strokeWidth: widget._indicatorStyle?.strokeWidth ?? IndicatorStyle.defaultStrokeWidth,
                        ),
                      ),
                      Opacity(opacity: 0.001, child: widget.child),
                    ],
                  ),
          )
        : CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _onPressedCallback,
            child: !_isProcessing
                ? widget.child
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      CupertinoActivityIndicator(
                        color: widget._indicatorStyle?.color ?? context.theme.colorScheme.onPrimary,
                        radius: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius,
                      ),
                      Opacity(opacity: 0.001, child: widget.child),
                    ],
                  ),
          );
  }
}

@immutable
class CoreTextButton extends StatefulWidget {
  const CoreTextButton({
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  })  : _autoIndicator = false,
        _indicatorStyle = null;

  const CoreTextButton.autoIndicator({
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
    IndicatorStyle? indicatorStyle,
  })  : _autoIndicator = true,
        _indicatorStyle = indicatorStyle;

  final Widget child;
  final FutureOr<dynamic> Function()? onPressed;
  final EdgeInsetsGeometry padding;
  final double minSize;
  final BorderRadius borderRadius;
  final bool _autoIndicator;
  final IndicatorStyle? _indicatorStyle;

  @override
  State<CoreTextButton> createState() => _CoreTextButtonState();
}

class _CoreTextButtonState extends State<CoreTextButton> {
  var _isProcessing = false;

  Future<dynamic> _onPressedCallback() async {
    if (widget.onPressed == null) return;
    if (!widget._autoIndicator) return await widget.onPressed!.call();
    setState(() => _isProcessing = true);
    final overlayEntry = OverlayEntry(builder: (context) => const Positioned.fill(child: AbsorbPointer()));
    Overlay.of(context).insert(overlayEntry);
    try {
      await widget.onPressed!.call();
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoButton(
          onPressed: _onPressedCallback,
          padding: widget.padding,
          minSize: widget.minSize,
          child: !_isProcessing
              ? widget.child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.child,
                    horizontalBox12,
                    CupertinoActivityIndicator(
                      color: widget._indicatorStyle?.color,
                      radius: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius,
                    ),
                  ],
                ),
        ),
      _ => TextButton(
          onPressed: _onPressedCallback,
          style: TextButton.styleFrom(
            padding: widget.padding,
            minimumSize: Size(widget.minSize, widget.minSize),
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius,
            ),
          ),
          child: !_isProcessing
              ? widget.child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.child,
                    horizontalBox12,
                    SizedBox(
                      width: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      height: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      child: CircularProgressIndicator(
                        color: widget._indicatorStyle?.color,
                        strokeWidth: widget._indicatorStyle?.strokeWidth ?? IndicatorStyle.defaultStrokeWidth,
                      ),
                    ),
                  ],
                ),
        ),
    };
  }
}

@immutable
class CoreOutlinedButton extends StatefulWidget {
  const CoreOutlinedButton({
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  })  : _autoIndicator = false,
        _indicatorStyle = null;

  const CoreOutlinedButton.autoIndicator({
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
    IndicatorStyle? indicatorStyle,
  })  : _autoIndicator = true,
        _indicatorStyle = indicatorStyle;

  final Widget child;
  final FutureOr<dynamic> Function()? onPressed;
  final EdgeInsetsGeometry padding;
  final double minSize;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final bool _autoIndicator;
  final IndicatorStyle? _indicatorStyle;

  @override
  State<CoreOutlinedButton> createState() => _CoreOutlinedButtonState();
}

class _CoreOutlinedButtonState extends State<CoreOutlinedButton> {
  var _isProcessing = false;

  Future<dynamic> _onPressedCallback() async {
    if (widget.onPressed == null) return;
    if (!widget._autoIndicator) return await widget.onPressed!.call();
    setState(() => _isProcessing = true);
    final overlayEntry = OverlayEntry(builder: (context) => const Positioned.fill(child: AbsorbPointer()));
    Overlay.of(context).insert(overlayEntry);
    try {
      await widget.onPressed!.call();
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => OutlinedButton(
          onPressed: _onPressedCallback,
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            padding: widget.padding,
            side: BorderSide(color: widget.borderColor ?? context.colorScheme.primary),
            minimumSize: Size(widget.minSize, widget.minSize),
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius,
            ),
          ),
          child: !_isProcessing
              ? widget.child
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      height: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      child: CupertinoActivityIndicator(
                        color: widget._indicatorStyle?.color,
                        radius: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius,
                      ),
                    ),
                    Opacity(opacity: 0.001, child: widget.child),
                  ],
                ),
        ),
      _ => OutlinedButton(
          onPressed: _onPressedCallback,
          style: OutlinedButton.styleFrom(
            padding: widget.padding,
            side: BorderSide(color: widget.borderColor ?? context.colorScheme.primary),
            minimumSize: Size(widget.minSize, widget.minSize),
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius,
            ),
          ),
          child: !_isProcessing
              ? widget.child
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      height: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      child: CircularProgressIndicator(
                        color: widget._indicatorStyle?.color,
                        strokeWidth: widget._indicatorStyle?.strokeWidth ?? IndicatorStyle.defaultStrokeWidth,
                      ),
                    ),
                    Opacity(opacity: 0.001, child: widget.child),
                  ],
                ),
        ),
    };
  }
}

@immutable
class CoreFilledButton extends StatefulWidget {
  const CoreFilledButton({
    required this.child,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    super.key,
  })  : _autoIndicator = false,
        _indicatorStyle = null;

  const CoreFilledButton.autoIndicator({
    required this.child,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    super.key,
    IndicatorStyle? indicatorStyle,
  })  : _autoIndicator = true,
        _indicatorStyle = indicatorStyle;

  final Widget child;
  final FutureOr<dynamic> Function()? onPressed;
  final BorderRadius borderRadius;
  final double minSize;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool _autoIndicator;
  final IndicatorStyle? _indicatorStyle;

  @override
  State<CoreFilledButton> createState() => _CoreFilledButtonState();
}

class _CoreFilledButtonState extends State<CoreFilledButton> {
  var _isProcessing = false;

  Future<dynamic> _onPressedCallback() async {
    if (widget.onPressed == null) return;
    if (!widget._autoIndicator) return await widget.onPressed!.call();
    setState(() => _isProcessing = true);
    final overlayEntry = OverlayEntry(builder: (context) => const Positioned.fill(child: AbsorbPointer()));
    Overlay.of(context).insert(overlayEntry);
    try {
      await widget.onPressed!.call();
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoButton(
          onPressed: _onPressedCallback,
          padding: widget.padding,
          color: widget.backgroundColor ?? context.theme.colorScheme.primary,
          minSize: widget.minSize,
          borderRadius: widget.borderRadius,
          child: !_isProcessing
              ? widget.child
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    CupertinoActivityIndicator(
                      color: widget._indicatorStyle?.color ?? context.theme.colorScheme.onPrimary,
                      radius: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius,
                    ),
                    Opacity(opacity: 0.001, child: widget.child),
                  ],
                ),
        ),
      _ => FilledButton(
          onPressed: _onPressedCallback,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius,
            ),
            minimumSize: Size(widget.minSize, widget.minSize),
            backgroundColor: widget.backgroundColor,
            padding: widget.padding,
          ),
          child: !_isProcessing
              ? widget.child
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      height: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                      child: CircularProgressIndicator(
                        color: widget._indicatorStyle?.color ?? context.theme.colorScheme.onPrimary,
                        strokeWidth: widget._indicatorStyle?.strokeWidth ?? IndicatorStyle.defaultStrokeWidth,
                      ),
                    ),
                    Opacity(opacity: 0.001, child: widget.child),
                  ],
                ),
        ),
    };
  }
}

@immutable
class CoreIconButton extends StatefulWidget {
  const CoreIconButton({
    required this.icon,
    required this.onPressed,
    this.radius = kMinInteractiveDimensionCupertino * 0.5,
    super.key,
  })  : filled = false,
        backgroundColor = null,
        _autoIndicator = false,
        _indicatorStyle = null;

  const CoreIconButton.filled({
    required this.icon,
    required this.onPressed,
    this.radius = kMinInteractiveDimensionCupertino * 0.5,
    this.backgroundColor,
    super.key,
  })  : filled = true,
        _autoIndicator = false,
        _indicatorStyle = null;

  const CoreIconButton.autoIndicator({
    required this.icon,
    required this.onPressed,
    this.radius = kMinInteractiveDimensionCupertino * 0.5,
    this.backgroundColor,
    super.key,
    IndicatorStyle? indicatorStyle,
  })  : filled = false,
        _autoIndicator = true,
        _indicatorStyle = indicatorStyle;

  const CoreIconButton.filledAutoIndicator({
    required this.icon,
    required this.onPressed,
    this.radius = kMinInteractiveDimensionCupertino * 0.5,
    this.backgroundColor,
    super.key,
    IndicatorStyle? indicatorStyle,
  })  : filled = true,
        _autoIndicator = true,
        _indicatorStyle = indicatorStyle;

  final Widget icon;
  final FutureOr<dynamic> Function()? onPressed;
  final bool filled;
  final double radius;
  final Color? backgroundColor;
  final bool _autoIndicator;
  final IndicatorStyle? _indicatorStyle;

  @override
  State<CoreIconButton> createState() => _CoreIconButtonState();
}

class _CoreIconButtonState extends State<CoreIconButton> {
  var _isProcessing = false;

  Future<dynamic> _onPressedCallback() async {
    if (widget.onPressed == null) return;
    if (!widget._autoIndicator) return await widget.onPressed!.call();
    setState(() => _isProcessing = true);
    final overlayEntry = OverlayEntry(builder: (context) => const Positioned.fill(child: AbsorbPointer()));
    Overlay.of(context).insert(overlayEntry);
    try {
      await widget.onPressed!.call();
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      overlayEntry.remove();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoButton(
          onPressed: _onPressedCallback,
          padding: EdgeInsets.zero,
          minSize: widget.radius * 2,
          child: widget.filled
              ? CircleAvatar(
                  backgroundColor: widget.backgroundColor ?? context.theme.colorScheme.primary,
                  radius: widget.radius,
                  child: !_isProcessing
                      ? widget.icon
                      : CupertinoActivityIndicator(
                          color: widget._indicatorStyle?.color ?? context.theme.colorScheme.onPrimary,
                          radius: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius,
                        ),
                )
              : !_isProcessing
                  ? widget.icon
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        CupertinoActivityIndicator(
                          color: widget._indicatorStyle?.color,
                          radius: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius,
                        ),
                        Opacity(opacity: 0.001, child: widget.icon),
                      ],
                    ),
        ),
      _ => widget.filled
          ? IconButton.filled(
              onPressed: _onPressedCallback,
              icon: !_isProcessing
                  ? widget.icon
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                          height: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                          child: CircularProgressIndicator(
                            color: widget._indicatorStyle?.color ?? context.theme.colorScheme.onPrimary,
                            strokeWidth: widget._indicatorStyle?.strokeWidth ?? IndicatorStyle.defaultStrokeWidth,
                          ),
                        ),
                        Opacity(opacity: 0.001, child: widget.icon),
                      ],
                    ),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                minimumSize: Size(widget.radius * 2, widget.radius * 2),
                backgroundColor: widget.backgroundColor,
              ),
            )
          : IconButton(
              onPressed: _onPressedCallback,
              icon: !_isProcessing
                  ? widget.icon
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                          height: widget._indicatorStyle?.radius ?? IndicatorStyle.defaultRadius * 2,
                          child: CircularProgressIndicator(
                            color: widget._indicatorStyle?.color ,
                            strokeWidth: widget._indicatorStyle?.strokeWidth ?? IndicatorStyle.defaultStrokeWidth,
                          ),
                        ),
                        Opacity(opacity: 0.001, child: widget.icon),
                      ],
                    ),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                minimumSize: Size(widget.radius * 2, widget.radius * 2),
              ),
            ),
    };
  }
}
