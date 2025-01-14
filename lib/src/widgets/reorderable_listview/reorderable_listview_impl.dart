import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_core/flutter_core.dart';

enum _CoreReorderableListViewType {
  normal,
  builder,
}

class CoreReorderableListView extends StatefulWidget {
  CoreReorderableListView({
    required List<Widget> children,
    required this.onReorder,
    super.key,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.proxyDecorator,
    this.buildDefaultDragHandles = true,
    this.padding,
    this.header,
    this.footer,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoScrollerVelocityScalar,
    this.onReachedEnd,
    this.onReachedEndPercentage = 0.7,
    this.onRefresh,
  })  : _listViewType = _CoreReorderableListViewType.normal,
        itemBuilder = ((BuildContext context, int index) => children[index]),
        itemCount = children.length;

  const CoreReorderableListView.builder({
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    super.key,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.proxyDecorator,
    this.buildDefaultDragHandles = true,
    this.padding,
    this.header,
    this.footer,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoScrollerVelocityScalar,
    this.onReachedEnd,
    this.onReachedEndPercentage = 0.7,
    this.onRefresh,
  }) : _listViewType = _CoreReorderableListViewType.builder;

  final _CoreReorderableListViewType _listViewType;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  final ReorderCallback onReorder;
  final void Function(int index)? onReorderStart;
  final void Function(int index)? onReorderEnd;
  final double? itemExtent;
  final ItemExtentBuilder? itemExtentBuilder;
  final Widget? prototypeItem;
  final ReorderItemProxyDecorator? proxyDecorator;
  final bool buildDefaultDragHandles;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;
  final Axis scrollDirection;
  final bool reverse;
  @Deprecated('Use controller property instead')
  final ScrollController? scrollController;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double anchor;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final double? autoScrollerVelocityScalar;
  final FutureOr<void> Function()? onReachedEnd;
  final double onReachedEndPercentage;
  final Future<void> Function()? onRefresh;

  @override
  State<CoreReorderableListView> createState() => _CoreReorderableListViewState();
}

class _CoreReorderableListViewState extends State<CoreReorderableListView> {
  late final ScrollController _scrollController;
  bool _showIndicator = false;
  ScrollController? _primaryScrollController;
  late ScrollPosition _position;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primaryScrollController = PrimaryScrollController.maybeOf(context)?..attach(_position = _scrollController.position);
    });
  }

  @override
  void dispose() {
    _primaryScrollController?.detach(_position);
    _scrollController.removeListener(_onScroll);
    if (widget.controller.isNotNull || widget.scrollController.isNotNull) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget._listViewType) {
      _CoreReorderableListViewType.normal => _reorderableListView,
      _CoreReorderableListViewType.builder => _reorderableListViewBuilder,
    };
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final animValue = Curves.easeInOut.transform(animation.value);
        final elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          color: Colors.transparent,
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
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

  Widget get _reorderableListView {
    final listView = ReorderableListView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      onReorder: widget.onReorder,
      onReorderStart: widget.onReorderStart,
      onReorderEnd: widget.onReorderEnd,
      itemExtent: widget.itemExtent,
      itemExtentBuilder: widget.itemExtentBuilder,
      prototypeItem: widget.prototypeItem,
      proxyDecorator: widget.proxyDecorator,
      buildDefaultDragHandles: widget.buildDefaultDragHandles,
      padding: widget.padding,
      header: widget.header,
      footer: widget.footer,
      scrollController: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      autoScrollerVelocityScalar: widget.autoScrollerVelocityScalar,
      children: [
        ...List.generate(widget.itemCount, (index) => widget.itemBuilder(context, index)),
        if (_showIndicator) _ListViewAdaptiveIndicator(),
      ],
    );
    return widget.onRefresh.isNull
        ? listView
        : Platform.isAndroid
            ? RefreshIndicator(onRefresh: widget.onRefresh!, child: listView)
            : _CustomScrollView(
                sliver: SliverReorderableList(
                  itemBuilder: (context, index) {
                    if (index == widget.itemCount) return _ListViewAdaptiveIndicator();
                    final item = widget.itemBuilder(context, index);
                    final Key itemGlobalKey = _ReorderableListViewChildGlobalKey(item.key!, this);
                    return Material(
                      color: Colors.transparent,
                      key: itemGlobalKey,
                      child: ReorderableDelayedDragStartListener(index: index, child: item),
                    );
                  },
                  itemCount: _showIndicator ? widget.itemCount + 1 : widget.itemCount,
                  proxyDecorator: widget.proxyDecorator ?? _proxyDecorator,
                  onReorder: widget.onReorder,
                  onReorderStart: widget.onReorderStart,
                  onReorderEnd: widget.onReorderEnd,
                  itemExtent: widget.itemExtent,
                  itemExtentBuilder: widget.itemExtentBuilder,
                ),
              );
  }

  Widget get _reorderableListViewBuilder {
    final listView = ReorderableListView.builder(
      itemBuilder: (context, index) {
        if (index == widget.itemCount) return _ListViewAdaptiveIndicator();
        return widget.itemBuilder(context, index);
      },
      itemCount: _showIndicator ? widget.itemCount + 1 : widget.itemCount,
      onReorder: widget.onReorder,
      onReorderStart: widget.onReorderStart,
      onReorderEnd: widget.onReorderEnd,
      itemExtent: widget.itemExtent,
      itemExtentBuilder: widget.itemExtentBuilder,
      prototypeItem: widget.prototypeItem,
      proxyDecorator: widget.proxyDecorator,
      buildDefaultDragHandles: widget.buildDefaultDragHandles,
      padding: widget.padding,
      header: widget.header,
      footer: widget.footer,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      scrollController: _scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      autoScrollerVelocityScalar: widget.autoScrollerVelocityScalar,
    );

    return widget.onRefresh.isNull
        ? listView
        : Platform.isAndroid
            ? RefreshIndicator(onRefresh: widget.onRefresh!, child: listView)
            : _CustomScrollView(
                sliver: SliverReorderableList(
                  itemBuilder: (context, index) {
                    if (index == widget.itemCount) return _ListViewAdaptiveIndicator();
                    final item = widget.itemBuilder(context, index);
                    final Key itemGlobalKey = _ReorderableListViewChildGlobalKey(item.key!, this);
                    return Material(
                      color: Colors.transparent,
                      key: itemGlobalKey,
                      child: ReorderableDelayedDragStartListener(index: index, child: item),
                    );
                  },
                  itemCount: _showIndicator ? widget.itemCount + 1 : widget.itemCount,
                  proxyDecorator: widget.proxyDecorator ?? _proxyDecorator,
                  onReorder: widget.onReorder,
                  onReorderStart: widget.onReorderStart,
                  onReorderEnd: widget.onReorderEnd,
                  itemExtent: widget.itemExtent,
                  itemExtentBuilder: widget.itemExtentBuilder,
                ),
              );
  }
}

@immutable
final class _ListViewAdaptiveIndicator extends StatelessWidget {
  _ListViewAdaptiveIndicator() : super(key: UniqueKey());

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
    final state = context.findAncestorStateOfType<_CoreReorderableListViewState>();
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

class _ReorderableListViewChildGlobalKey extends GlobalObjectKey {
  const _ReorderableListViewChildGlobalKey(this.subKey, this.state) : super(subKey);

  final Key subKey;
  final State state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ReorderableListViewChildGlobalKey && other.subKey == subKey && other.state == state;
  }

  @override
  int get hashCode => Object.hash(subKey, state);
}
