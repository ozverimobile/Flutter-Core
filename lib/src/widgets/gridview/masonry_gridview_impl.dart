import 'dart:async';
import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_ui/material_ui.dart';

enum _CoreMasonryGridViewType {
  normal,
  builder,
  count,
  extent,
}

class CoreMasonryGridView extends StatefulWidget {
  const CoreMasonryGridView({
    required this.gridDelegate,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.children = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.onReachedEnd,
    this.onReachedEndPercentage = 0.7,
    this.onRefresh,
    this.floatingChild,
    this.floatingChildVisibilityCallback,
    this.refreshIndicatorStartPosition = .above,
  }) : _gridViewType = _CoreMasonryGridViewType.normal,
       _itemBuilder = null,
       itemCount = null,
       crossAxisCount = null,
       maxCrossAxisExtent = null;

  const CoreMasonryGridView.builder({
    required this.gridDelegate,
    required IndexedWidgetBuilder itemBuilder,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.onReachedEnd,
    this.onReachedEndPercentage = 0.7,
    this.onRefresh,
    this.floatingChild,
    this.floatingChildVisibilityCallback,
    this.refreshIndicatorStartPosition = .above,
  }) : _gridViewType = _CoreMasonryGridViewType.builder,
       _itemBuilder = itemBuilder,
       children = null,
       crossAxisCount = null,
       maxCrossAxisExtent = null;

  const CoreMasonryGridView.count({
    required this.crossAxisCount,
    required IndexedWidgetBuilder itemBuilder,
    super.key,
    this.itemCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.onReachedEnd,
    this.onReachedEndPercentage = 0.7,
    this.onRefresh,
    this.floatingChild,
    this.floatingChildVisibilityCallback,
    this.refreshIndicatorStartPosition = .above,
  }) : _gridViewType = _CoreMasonryGridViewType.count,
       gridDelegate = null,
       _itemBuilder = itemBuilder,
       children = null,
       maxCrossAxisExtent = null;

  const CoreMasonryGridView.extent({
    required this.maxCrossAxisExtent,
    required IndexedWidgetBuilder itemBuilder,
    super.key,
    this.itemCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.onReachedEnd,
    this.onReachedEndPercentage = 0.7,
    this.onRefresh,
    this.floatingChild,
    this.floatingChildVisibilityCallback,
    this.refreshIndicatorStartPosition = .above,
  }) : _gridViewType = _CoreMasonryGridViewType.extent,
       gridDelegate = null,
       _itemBuilder = itemBuilder,
       children = null,
       crossAxisCount = null;

  final _CoreMasonryGridViewType _gridViewType;
  final SliverSimpleGridDelegate? gridDelegate;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final IndexedWidgetBuilder? _itemBuilder;
  final List<Widget>? children;
  final int? itemCount;
  final int? crossAxisCount;
  final double? maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final FutureOr<void> Function()? onReachedEnd;
  final double onReachedEndPercentage;
  final Future<void> Function()? onRefresh;

  /// Optional header-like widget placed at the top of the grid.
  ///
  /// Behaves like `SliverAppBar(floating: true, snap: true)`:
  /// the widget scrolls out with the content as the user scrolls down and
  /// snaps back (with a fade-in) as soon as the user scrolls up.
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
  State<CoreMasonryGridView> createState() => _CoreMasonryGridViewState();
}

class _CoreMasonryGridViewState extends State<CoreMasonryGridView> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool _showIndicator = false;
  ScrollController? _primaryScrollController;
  late ScrollPosition _position;

  /// Measured height of [CoreMasonryGridView.floatingChild].
  ///
  /// Required because [SliverPersistentHeader] needs a fixed extent.
  double? _floatingChildHeight;
  final GlobalKey _floatingChildMeasureKey = GlobalKey();

  SliverSimpleGridDelegate get _resolvedGridDelegate {
    switch (widget._gridViewType) {
      case _CoreMasonryGridViewType.normal:
      case _CoreMasonryGridViewType.builder:
        return widget.gridDelegate!;
      case _CoreMasonryGridViewType.count:
        return SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.crossAxisCount!);
      case _CoreMasonryGridViewType.extent:
        return SliverSimpleGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: widget.maxCrossAxisExtent!);
    }
  }

  int? get _effectiveItemCount {
    if (widget.itemCount == null) return null;
    return _showIndicator ? widget.itemCount! + 1 : widget.itemCount!;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primaryScrollController = PrimaryScrollController.maybeOf(context)?..attach(_position = _scrollController.position);
    });
  }

  @override
  void dispose() {
    _primaryScrollController?.detach(_position);
    _scrollController.removeListener(_onScroll);
    if (widget.controller.isNull) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.floatingChild != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureFloatingChild());
      return _buildWithFloatingChild();
    }

    return switch (widget._gridViewType) {
      _CoreMasonryGridViewType.normal => _gridView,
      _CoreMasonryGridViewType.builder => _gridViewBuilder,
      _CoreMasonryGridViewType.count => _gridViewCount,
      _CoreMasonryGridViewType.extent => _gridViewExtent,
    };
  }

  Future<void> _onScroll() async {
    if (!_isBottom || _showIndicator) return;

    setState(() => _showIndicator = true);
    await widget.onReachedEnd?.call();
    setState(() => _showIndicator = false);
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * widget.onReachedEndPercentage);
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

  Widget _buildGridSliver() {
    switch (widget._gridViewType) {
      case _CoreMasonryGridViewType.normal:
        return SliverMasonryGrid(
          gridDelegate: _resolvedGridDelegate,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          delegate: SliverChildListDelegate(
            [
              ...widget.children!,
              if (_showIndicator) const _MasonryGridViewAdaptiveIndicator(),
            ],
          ),
        );
      case _CoreMasonryGridViewType.builder:
      case _CoreMasonryGridViewType.count:
      case _CoreMasonryGridViewType.extent:
        return SliverMasonryGrid(
          gridDelegate: _resolvedGridDelegate,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == widget.itemCount) return const _MasonryGridViewAdaptiveIndicator();
              return widget._itemBuilder!(context, index);
            },
            childCount: widget.itemCount == null ? 0 : _effectiveItemCount,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addSemanticIndexes: widget.addSemanticIndexes,
          ),
        );
    }
  }

  Widget _buildWithFloatingChild() {
    final floatingChild = widget.floatingChild!;
    final height = _floatingChildHeight;

    final gridSliver = SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: _buildGridSliver(),
    );

    final customScrollView = CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: [
        if (Platform.isIOS && widget.onRefresh != null && widget.refreshIndicatorStartPosition == .above) CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
        SliverPersistentHeader(
          key: const ValueKey<String>('_core_masonry_gridview_floating_header'),
          floating: true,
          delegate: _MasonryFloatingChildHeaderDelegate(
            height: height ?? 0,
            vsync: this,
            child: floatingChild,
            onVisibilityChanged: widget.floatingChildVisibilityCallback,
          ),
        ),
        if (Platform.isIOS && widget.onRefresh != null && widget.refreshIndicatorStartPosition == .below) CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
        gridSliver,
      ],
    );

    final scrollable = Platform.isAndroid && widget.onRefresh != null
        ? RefreshIndicator(
            edgeOffset: widget.refreshIndicatorStartPosition == .below ? _floatingChildHeight ?? 0 : 0,
            onRefresh: widget.onRefresh!,
            child: customScrollView,
          )
        : customScrollView;

    return Stack(
      children: [
        Positioned.fill(child: scrollable),
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

  Widget get _gridView {
    final gridView = MasonryGridView(
      gridDelegate: _resolvedGridDelegate,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      children: [
        ...widget.children!,
        if (_showIndicator) const _MasonryGridViewAdaptiveIndicator(),
      ],
    );
    return widget.onRefresh.isNull
        ? gridView
        : Platform.isAndroid
        ? RefreshIndicator(onRefresh: widget.onRefresh!, child: gridView)
        : _MasonryGridCustomScrollView(sliver: _buildGridSliver());
  }

  Widget get _gridViewBuilder {
    final gridView = MasonryGridView.builder(
      gridDelegate: _resolvedGridDelegate,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemBuilder: (context, index) {
        if (index == widget.itemCount) return const _MasonryGridViewAdaptiveIndicator();
        return widget._itemBuilder!(context, index);
      },
      itemCount: widget.itemCount == null ? 0 : _effectiveItemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
    );

    return widget.onRefresh.isNull
        ? gridView
        : Platform.isAndroid
        ? RefreshIndicator(onRefresh: widget.onRefresh!, child: gridView)
        : _MasonryGridCustomScrollView(sliver: _buildGridSliver());
  }

  Widget get _gridViewCount {
    final gridView = MasonryGridView.count(
      crossAxisCount: widget.crossAxisCount!,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemBuilder: (context, index) {
        if (index == widget.itemCount) return const _MasonryGridViewAdaptiveIndicator();
        return widget._itemBuilder!(context, index);
      },
      itemCount: widget.itemCount == null ? 0 : _effectiveItemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
    );

    return widget.onRefresh.isNull
        ? gridView
        : Platform.isAndroid
        ? RefreshIndicator(onRefresh: widget.onRefresh!, child: gridView)
        : _MasonryGridCustomScrollView(sliver: _buildGridSliver());
  }

  Widget get _gridViewExtent {
    final gridView = MasonryGridView.extent(
      maxCrossAxisExtent: widget.maxCrossAxisExtent!,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemBuilder: (context, index) {
        if (index == widget.itemCount) return const _MasonryGridViewAdaptiveIndicator();
        return widget._itemBuilder!(context, index);
      },
      itemCount: widget.itemCount == null ? 0 : _effectiveItemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
    );

    return widget.onRefresh.isNull
        ? gridView
        : Platform.isAndroid
        ? RefreshIndicator(onRefresh: widget.onRefresh!, child: gridView)
        : _MasonryGridCustomScrollView(sliver: _buildGridSliver());
  }
}

@immutable
final class _MasonryGridViewAdaptiveIndicator extends StatelessWidget {
  const _MasonryGridViewAdaptiveIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

/// iOS style custom scroll view with refresh indicator.
@immutable
final class _MasonryGridCustomScrollView extends StatefulWidget {
  const _MasonryGridCustomScrollView({
    required this.sliver,
  });

  final Widget sliver;

  @override
  State<_MasonryGridCustomScrollView> createState() => _MasonryGridCustomScrollViewState();
}

class _MasonryGridCustomScrollViewState extends State<_MasonryGridCustomScrollView> {
  var _isAtTop = true;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_CoreMasonryGridViewState>();
    if (state.isNull) return emptyBox;
    final widget = state!.widget;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          if (state._scrollController.offset <= 0 && !_isAtTop) {
            scheduleMicrotask(() {
              if (mounted) {
                setState(() {
                  _isAtTop = true;
                });
              }
            });
          } else if (state._scrollController.offset > 0 && _isAtTop) {
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
        physics: widget.physics,
        cacheExtent: widget.cacheExtent,
        clipBehavior: widget.clipBehavior,
        controller: state._scrollController,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        primary: widget.primary,
        restorationId: widget.restorationId,
        reverse: widget.reverse,
        scrollDirection: widget.scrollDirection,
        semanticChildCount: widget.semanticChildCount,
        shrinkWrap: widget.shrinkWrap,
        slivers: [
          if (_isAtTop) CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
          SliverPadding(padding: widget.padding ?? EdgeInsets.zero, sliver: this.widget.sliver),
        ],
      ),
    );
  }
}

class _MasonryFloatingChildHeaderDelegate extends SliverPersistentHeaderDelegate {
  _MasonryFloatingChildHeaderDelegate({
    required this.height,
    required this.vsync,
    required this.child,
    this.onVisibilityChanged,
  });

  final double height;
  final Widget child;
  final FloatingChildVisibilityCallback? onVisibilityChanged;

  bool? _lastReportedVisibility;

  @override
  final TickerProvider vsync;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = maxExtent == 0 ? 1.0 : (1.0 - (shrinkOffset / maxExtent)).clamp(0.0, 1.0);

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
  bool shouldRebuild(covariant _MasonryFloatingChildHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child || oldDelegate.onVisibilityChanged != onVisibilityChanged;
  }
}
