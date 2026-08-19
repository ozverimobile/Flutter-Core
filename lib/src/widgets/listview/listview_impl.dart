import 'dart:async';
import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:material_ui/material_ui.dart';

enum _CoreListViewType {
  normal,
  builder,
  separated,
}

/// Signature for callbacks that report the visibility state of
/// [CoreListView.floatingChild].
///
/// [isVisible] is `true` whenever the floating header is currently painted
/// on screen (fully or partially) and `false` once it has scrolled out
/// completely.
typedef FloatingChildVisibilityCallback = void Function(bool isVisible);

class CoreListView extends StatefulWidget {
  const CoreListView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
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
  }) : _listViewType = _CoreListViewType.normal,
       _itemBuilder = null,
       _separatorBuilder = null,
       findChildIndexCallback = null,
       itemCount = null;

  const CoreListView.builder({
    required IndexedWidgetBuilder itemBuilder,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.findChildIndexCallback,
    this.itemCount,
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
  }) : _listViewType = _CoreListViewType.builder,
       _separatorBuilder = null,
       _itemBuilder = itemBuilder,
       children = null;

  const CoreListView.separated({
    required IndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.findChildIndexCallback,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.semanticChildCount,
    this.onReachedEnd,
    this.onReachedEndPercentage = 0.7,
    this.onRefresh,
    this.floatingChild,
    this.floatingChildVisibilityCallback,
    this.refreshIndicatorStartPosition = .above,
  }) : _listViewType = _CoreListViewType.separated,
       _separatorBuilder = separatorBuilder,
       _itemBuilder = itemBuilder,
       children = null;

  final _CoreListViewType _listViewType;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final ItemExtentBuilder? itemExtentBuilder;
  final Widget? prototypeItem;
  final IndexedWidgetBuilder? _itemBuilder;
  final List<Widget>? children;
  final IndexedWidgetBuilder? _separatorBuilder;
  final ChildIndexGetter? findChildIndexCallback;
  final int? itemCount;
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

  /// Optional header-like widget placed at the top of the list.
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
  State<CoreListView> createState() => _CoreListViewState();
}

class _CoreListViewState extends State<CoreListView> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool _showIndicator = false;
  ScrollController? _primaryScrollController;
  late ScrollPosition _position;

  /// Measured height of [CoreListView.floatingChild].
  ///
  /// Required because [SliverPersistentHeader] needs a fixed extent.
  double? _floatingChildHeight;
  final GlobalKey _floatingChildMeasureKey = GlobalKey();

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
      /// Schedule a measurement after layout so [_floatingChildHeight] can be
      /// fed into [SliverPersistentHeader] on the next build.
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureFloatingChild());
      return _buildWithFloatingChild();
    }

    return switch (widget._listViewType) {
      _CoreListViewType.normal => _listView,
      _CoreListViewType.builder => _listViewBuilder,
      _CoreListViewType.separated => _listViewSeparated,
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

  /// Builds the sliver representing the underlying list. Used only on the
  /// floating-child code path and on the iOS refresh path.
  Widget _buildListSliver() {
    switch (widget._listViewType) {
      case _CoreListViewType.normal:
        return SliverList(
          delegate: SliverChildListDelegate(
            [
              ...widget.children!,
              if (_showIndicator) const _ListViewAdaptiveIndicator(),
            ],
          ),
        );
      case _CoreListViewType.builder:
        return SliverList.builder(
          itemBuilder: (context, index) {
            if (index == widget.itemCount!) return const _ListViewAdaptiveIndicator();
            return widget._itemBuilder!(context, index);
          },
          itemCount: widget.itemCount == null
              ? 0
              : _showIndicator
              ? widget.itemCount! + 1
              : widget.itemCount!,
        );
      case _CoreListViewType.separated:
        return SliverList.separated(
          itemBuilder: (context, index) {
            if (index == widget.itemCount!) return const _ListViewAdaptiveIndicator();
            return widget._itemBuilder!(context, index);
          },
          separatorBuilder: widget._separatorBuilder!,
          itemCount: widget.itemCount == null
              ? 0
              : _showIndicator
              ? widget.itemCount! + 1
              : widget.itemCount!,
        );
    }
  }

  /// Builds the scroll view when [CoreListView.floatingChild] is provided.
  ///
  /// Uses a unified [CustomScrollView] path (for both iOS and Android) so that
  /// the floating [SliverPersistentHeader] has a stable position in the sliver
  /// tree. The sliver list is intentionally kept the same length across
  /// rebuilds; otherwise the floating header's internal scroll listener can
  /// fire while its element is being reparented and crash with
  /// "Looking up a deactivated widget's ancestor is unsafe".
  Widget _buildWithFloatingChild() {
    final floatingChild = widget.floatingChild!;
    final height = _floatingChildHeight;

    final listSliver = SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: _buildListSliver(),
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
          key: const ValueKey<String>('_core_listview_floating_header'),
          floating: true,
          delegate: _FloatingChildHeaderDelegate(
            height: height ?? 0,
            vsync: this,
            child: floatingChild,
            onVisibilityChanged: widget.floatingChildVisibilityCallback,
          ),
        ),
        if (Platform.isIOS && widget.onRefresh != null && widget.refreshIndicatorStartPosition == .below) CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
        listSliver,
      ],
    );

    final scrollable = Platform.isAndroid && widget.onRefresh != null ? RefreshIndicator(edgeOffset: widget.refreshIndicatorStartPosition == .below ? _floatingChildHeight ?? 0 : 0, onRefresh: widget.onRefresh!, child: customScrollView) : customScrollView;

    return Stack(
      children: [
        Positioned.fill(child: scrollable),

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

  Widget get _listView {
    final listView = ListView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      itemExtentBuilder: widget.itemExtentBuilder,
      prototypeItem: widget.prototypeItem,
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
        if (_showIndicator) const _ListViewAdaptiveIndicator(),
      ],
    );
    return widget.onRefresh.isNull
        ? listView
        : Platform.isAndroid
        ? RefreshIndicator(onRefresh: widget.onRefresh!, child: listView)
        : _CustomScrollView(
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  ...widget.children!,
                  if (_showIndicator) const _ListViewAdaptiveIndicator(),
                ],
              ),
            ),
          );
  }

  Widget get _listViewBuilder {
    final listView = ListView.builder(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      itemExtentBuilder: widget.itemExtentBuilder,
      prototypeItem: widget.prototypeItem,
      itemBuilder: (context, index) {
        if (index == widget.itemCount!) return const _ListViewAdaptiveIndicator();
        return widget._itemBuilder!(context, index);
      },
      findChildIndexCallback: widget.findChildIndexCallback,
      itemCount: widget.itemCount == null
          ? 0
          : _showIndicator
          ? widget.itemCount! + 1
          : widget.itemCount!,
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
        ? listView
        : Platform.isAndroid
        ? RefreshIndicator(onRefresh: widget.onRefresh!, child: listView)
        : _CustomScrollView(
            sliver: SliverList.builder(
              itemBuilder: (context, index) {
                if (index == widget.itemCount!) return const _ListViewAdaptiveIndicator();
                return widget._itemBuilder!(context, index);
              },
              itemCount: widget.itemCount == null
                  ? 0
                  : _showIndicator
                  ? widget.itemCount! + 1
                  : widget.itemCount!,
            ),
          );
  }

  Widget get _listViewSeparated {
    final listView = ListView.separated(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemBuilder: (context, index) {
        if (index == widget.itemCount!) return const _ListViewAdaptiveIndicator();
        return widget._itemBuilder!(context, index);
      },
      findChildIndexCallback: widget.findChildIndexCallback,
      separatorBuilder: widget._separatorBuilder!,
      itemCount: widget.itemCount == null
          ? 0
          : _showIndicator
          ? widget.itemCount! + 1
          : widget.itemCount!,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
    );

    return widget.onRefresh.isNull
        ? listView
        : Platform.isAndroid
        ? RefreshIndicator(onRefresh: widget.onRefresh!, child: listView)
        : _CustomScrollView(
            sliver: SliverList.separated(
              itemBuilder: (context, index) {
                if (index == widget.itemCount!) return const _ListViewAdaptiveIndicator();
                return widget._itemBuilder!(context, index);
              },
              separatorBuilder: widget._separatorBuilder!,
              itemCount: widget.itemCount == null
                  ? 0
                  : _showIndicator
                  ? widget.itemCount! + 1
                  : widget.itemCount!,
            ),
          );
  }
}

@immutable
final class _ListViewAdaptiveIndicator extends StatelessWidget {
  const _ListViewAdaptiveIndicator();

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
final class _CustomScrollView extends StatefulWidget {
  const _CustomScrollView({
    required this.sliver,
  });

  final Widget sliver;

  @override
  State<_CustomScrollView> createState() => _CustomScrollViewState();
}

class _CustomScrollViewState extends State<_CustomScrollView> {
  /// Whether the scroll view is at the top.
  ///
  /// This is used to determine whether to show the refresh indicator.
  var _isAtTop = true;
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_CoreListViewState>();
    if (state.isNull) return emptyBox;
    final widget = state!.widget;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        /// Check if the scroll view is at the top.
        ///
        /// True when scroll offset <= 0. False otherwise.
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
          /// Show the refresh indicator only when the scroll view is at the top.
          if (_isAtTop) CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
          SliverPadding(padding: widget.padding ?? EdgeInsets.zero, sliver: this.widget.sliver),
        ],
      ),
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
