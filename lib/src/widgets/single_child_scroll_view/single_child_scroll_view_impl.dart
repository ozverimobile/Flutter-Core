import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class CoreSingleChildScrollView extends StatefulWidget {
  const CoreSingleChildScrollView({
    required this.child,
    required this.onRefresh,
    this.controller,
    super.key,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;

  @override
  State<CoreSingleChildScrollView> createState() => _CoreSingleChildScrollViewState();
}

class _CoreSingleChildScrollViewState extends State<CoreSingleChildScrollView> {
  /// Whether the scroll view is at the top.
  ///
  /// This is used to determine whether to show the refresh indicator.
  var _isAtTop = true;

  late final ScrollController _scrollController;
  ScrollController? _primaryScrollController;
  late ScrollPosition _position;

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

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: widget.child,
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
              slivers: [
                /// Show the refresh indicator only when the scroll view is at the top.
                if (_isAtTop) CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
                SliverToBoxAdapter(child: widget.child),
              ],
            ),
          );
  }
}
