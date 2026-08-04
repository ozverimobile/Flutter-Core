import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_core/flutter_core.dart';

class CoreSingleChildScrollView extends StatefulWidget {
  const CoreSingleChildScrollView({
    required this.child,
    required this.onRefresh,
    this.controller,
    this.floatingChild,
    this.floatingChildVisibilityCallback,
    this.refreshIndicatorStartPosition = .above,
    super.key,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;

  /// Optional header-like widget placed at the top of the scroll view.
  ///
  /// Behaves like `SliverAppBar(floating: true, snap: true)`:
  /// the widget scrolls out with the content as the user scrolls down and
  /// snaps back in as soon as the user scrolls up.
  final Widget? floatingChild;

  /// Called whenever the visibility of [floatingChild] changes.
  ///
  /// Fires with `true` when the header becomes visible again (snaps back in)
  /// and with `false` once it has fully scrolled out. Invocations are
  /// deduplicated and scheduled after the current frame to avoid
  /// `setState`-during-build errors on the listener side.
  final FloatingChildVisibilityCallback? floatingChildVisibilityCallback;

  final CoreRefreshIndicatorStartPosition refreshIndicatorStartPosition;

  @override
  State<CoreSingleChildScrollView> createState() => _CoreSingleChildScrollViewState();
}

class _CoreSingleChildScrollViewState extends State<CoreSingleChildScrollView> with TickerProviderStateMixin {
  /// Whether the scroll view is at the top.
  ///
  /// This is used to determine whether to show the refresh indicator.
  var _isAtTop = true;

  late final ScrollController _scrollController;
  ScrollController? _primaryScrollController;
  late ScrollPosition _position;

  /// Measured height of [CoreSingleChildScrollView.floatingChild].
  ///
  /// Required because [SliverPersistentHeader] needs a fixed extent.
  double? _floatingChildHeight;
  final GlobalKey _floatingChildMeasureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primaryScrollController = PrimaryScrollController.maybeOf(context)?..attach(_position = _scrollController.position);
    });
  }

 

  @override
  void dispose() {
    _primaryScrollController?.detach(_position);
    if (widget.controller.isNull) _scrollController.dispose();
    super.dispose();
  }

  void _measureFloatingChild() {
    if (!mounted) return;
    final renderObject = _floatingChildMeasureKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final newHeight = renderObject.size.height;
    if (newHeight <= 0 || _floatingChildHeight == newHeight) return;
    setState(() {
      _floatingChildHeight = newHeight;
    });
  }

  List<Widget> _buildSlivers({required bool withCupertinoRefresh}) {
    final floatingChild = widget.floatingChild;
    final height = _floatingChildHeight;
    return [
      if (withCupertinoRefresh && widget.refreshIndicatorStartPosition == .above)
        CupertinoSliverRefreshControl(
       
          onRefresh: widget.onRefresh,
        ),
      if (floatingChild != null)
        SliverPersistentHeader(
          floating: true,
          delegate: _FloatingChildHeaderDelegate(
            height: height ?? 0,
            vsync: this,
            child: floatingChild,
            onVisibilityChanged: widget.floatingChildVisibilityCallback,
          ),
        ),

      if (withCupertinoRefresh && widget.refreshIndicatorStartPosition == .below)
        CupertinoSliverRefreshControl(
          
          onRefresh: widget.onRefresh,
        ),

      SliverToBoxAdapter(child: widget.child),
    ];
  }

  Widget _buildScrollView() {
    return Platform.isAndroid
        ? RefreshIndicator(
            edgeOffset: widget.refreshIndicatorStartPosition == .below ? _floatingChildHeight ?? 0 : 0,
            onRefresh: widget.onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: _buildSlivers(withCupertinoRefresh: false),
            ),
          )
        : NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              /// Check if the scroll view is at the top.
              ///
              /// True when scroll offset <= 0. False otherwise.
              if (notification is ScrollStartNotification) {
                if (_scrollController.offset <= 0 && !_isAtTop) {
                  scheduleMicrotask(() {
                    if (mounted) {
                      setState(() {
                        _isAtTop = true;
                      });
                    }
                  });
                } else if (_scrollController.offset > 0 && _isAtTop) {
                  scheduleMicrotask(() {
                    if (mounted) {
                      setState(() {
                        _isAtTop = false;
                      });
                    }
                  });
                }
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,

              /// Show the refresh indicator only when the scroll view is at the top.
              slivers: _buildSlivers(withCupertinoRefresh: _isAtTop),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final floatingChild = widget.floatingChild;

    if (floatingChild == null) return _buildScrollView();

    /// Schedule a measurement after layout so [_floatingChildHeight] can be
    /// fed into [SliverPersistentHeader] on the next build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFloatingChild());

    return Stack(
      children: [
        Positioned.fill(child: _buildScrollView()),

        /// Invisible measurement widget. It participates in layout so we can
        /// read its intrinsic height, but it is not painted.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: IgnorePointer(
            child: Offstage(
              child: KeyedSubtree(
                key: _floatingChildMeasureKey,
                child: floatingChild,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingChildHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FloatingChildHeaderDelegate({
    required this.height,
    required this.vsync,
    required this.child,
    this.onVisibilityChanged,
  });

  final double height;
  final Widget child;
  final FloatingChildVisibilityCallback? onVisibilityChanged;

  /// Cached last reported visibility signal, used to de-duplicate callback
  /// invocations when [build] is called repeatedly with the same argument.
  bool? _lastReportedVisibility;

  @override
  final TickerProvider vsync;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    /// Fades the header in/out in sync with the floating snap animation.
    ///
    /// [shrinkOffset] is 0 when fully visible and grows up to [maxExtent]
    /// as the header scrolls out.
    final progress = maxExtent == 0 ? 1.0 : (1.0 - (shrinkOffset / maxExtent)).clamp(0.0, 1.0);

    /// The header is considered visible as long as it occupies any space on
    /// screen (progress > 0). Once fully scrolled out, progress is 0 and the
    /// header is reported as hidden.
    _notifyVisibilityIfChanged(progress > 0);

    final opacity = Curves.easeInOut.transform(progress);
    return Opacity(
      opacity: opacity,
      child: SizedBox.expand(child: child),
    );
  }

  void _notifyVisibilityIfChanged(bool isVisible) {
    final callback = onVisibilityChanged;
    if (callback == null) return;
    if (_lastReportedVisibility == isVisible) return;
    _lastReportedVisibility = isVisible;

    /// Defer to the next frame to avoid triggering setState during build on
    /// the listener side.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback(isVisible);
    });
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => FloatingHeaderSnapConfiguration(
    curve: Curves.easeInOut,
    duration: const Duration(milliseconds: 200),
  );

  @override
  bool shouldRebuild(covariant _FloatingChildHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child || oldDelegate.onVisibilityChanged != onVisibilityChanged;
  }
}
