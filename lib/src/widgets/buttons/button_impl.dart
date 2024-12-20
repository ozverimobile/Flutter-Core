import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

@immutable
class CoreButton extends StatelessWidget {
  const CoreButton({
    required this.child,
    required this.onPressed,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: onPressed,
            icon: child,
          )
        : CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: child,
          );
  }
}

@immutable
class CoreTextButton extends StatelessWidget {
  const CoreTextButton({
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double minSize;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoButton(
          onPressed: onPressed,
          padding: padding,
          minSize: minSize,
          child: child,
        ),
      _ => TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: padding,
            minimumSize: Size(minSize, minSize),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
          child: child,
        ),
    };
  }
}

@immutable
class CoreOutlinedButton extends StatelessWidget {
  const CoreOutlinedButton({
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minSize = kMinInteractiveDimensionCupertino,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double minSize;
  final Color? borderColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            padding: padding,
            side: BorderSide(color: borderColor ?? context.colorScheme.primary),
            minimumSize: Size(minSize, minSize),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
          child: child,
        ),
      _ => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding,
            side: BorderSide(color: borderColor ?? context.colorScheme.primary),
            minimumSize: Size(minSize, minSize),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
          child: child,
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

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoButton(
          onPressed: () async {
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
          },
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
          onPressed: () async {
            if (widget.onPressed == null) return;
            if (!widget._autoIndicator) return await widget.onPressed!.call();
            setState(() => _isProcessing = true);
            final overlayEntry = OverlayEntry(builder: (context) =>  const Positioned.fill(child: AbsorbPointer()));
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
          },
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
class CoreIconButton extends StatelessWidget {
  const CoreIconButton({
    required this.icon,
    required this.onPressed,
    this.radius = kMinInteractiveDimensionCupertino * 0.5,
    super.key,
  })  : filled = false,
        backgroundColor = null;

  const CoreIconButton.filled({
    required this.icon,
    required this.onPressed,
    this.radius = kMinInteractiveDimensionCupertino * 0.5,
    this.backgroundColor,
    super.key,
  }) : filled = true;

  final Widget icon;
  final VoidCallback? onPressed;
  final bool filled;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return switch (context.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          minSize: radius * 2,
          child: filled
              ? CircleAvatar(
                  backgroundColor: backgroundColor ?? context.theme.colorScheme.primary,
                  radius: radius,
                  child: icon,
                )
              : icon,
        ),
      _ => filled
          ? IconButton.filled(
              onPressed: onPressed,
              icon: icon,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                minimumSize: Size(radius * 2, radius * 2),
                backgroundColor: backgroundColor,
              ),
            )
          : IconButton(
              onPressed: onPressed,
              icon: icon,
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                minimumSize: Size(radius * 2, radius * 2),
              ),
            ),
    };
  }
}
