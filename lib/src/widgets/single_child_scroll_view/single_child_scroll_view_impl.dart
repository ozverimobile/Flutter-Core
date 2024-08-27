import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    _scrollController = widget.controller ?? ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  child: SizedBox(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: widget.child,
                  ),
                ),
              );
            },
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
                SliverFillRemaining(child: widget.child),
              ],
            ),
          );
  }
}
