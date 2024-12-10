import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

enum _ImageType { network, asset, memory, file }

enum _ScaleLevel { off, x2, x3 }

/// Vertical drag close threshold
///
/// [low] - 50
/// [medium] - 150
/// [high] - 250
enum VerticalDragCloseThreshold { low, medium, high }

typedef _PageIndicatorBuilder = Positioned Function(BuildContext context, int active, int total);

class CoreImageController {
  CoreImageController({GlobalKey<NavigatorState>? navigatorKey}) : _navigatorKey = navigatorKey;
  final GlobalKey<NavigatorState>? _navigatorKey;

  VoidCallback? _openContainer;
  void _init(VoidCallback openContainer) {
    _openContainer ??= openContainer;
  }

  void open() {
    _openContainer?.call();
  }

  void close() {
    if (_navigatorKey?.currentContext == null) throw Exception('Navigator key is null');
    Navigator.of(_navigatorKey!.currentContext!).pop();
  }
}

class CoreImageViewer extends StatelessWidget {
  const CoreImageViewer.network({
    required this.child,
    required List<String> images,
    this.verticalDragCloseThreshold = VerticalDragCloseThreshold.medium,
    this.openShape,
    this.closedShape,
    this.errorBuilder,
    this.loadingBuilder,
    this.backgroundColor = Colors.black,
    this.height,
    this.width,
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.closeButton,
    this.pageIndicator,
    this.initialIndex = 0,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.buttonAlignment = Alignment.topRight,
    this.buttonPadding = const EdgeInsets.only(top: 20, right: 20),
    this.showIndicator = true,
    this.indicatorAlignment = Alignment.bottomCenter,
    this.indicatorTextStyle = const TextStyle(color: Colors.white),
    this.indicatorPadding = EdgeInsets.zero,
    this.headers,
    this.controller,
    super.key,
  })  : _imageType = _ImageType.network,
        _images = images;

  const CoreImageViewer.asset({
    required this.child,
    required List<String> images,
    this.verticalDragCloseThreshold = VerticalDragCloseThreshold.medium,
    this.openShape,
    this.closedShape,
    this.errorBuilder,
    this.loadingBuilder,
    this.backgroundColor = Colors.black,
    this.height,
    this.width,
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.closeButton,
    this.pageIndicator,
    this.initialIndex = 0,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.buttonAlignment = Alignment.topRight,
    this.buttonPadding = const EdgeInsets.only(top: 20, right: 20),
    this.showIndicator = true,
    this.indicatorAlignment = Alignment.bottomCenter,
    this.indicatorTextStyle = const TextStyle(color: Colors.white),
    this.indicatorPadding = EdgeInsets.zero,
    this.headers,
    this.controller,
    super.key,
  })  : _imageType = _ImageType.asset,
        _images = images;

  const CoreImageViewer.file({
    required this.child,
    required List<File> images,
    this.verticalDragCloseThreshold = VerticalDragCloseThreshold.medium,
    this.openShape,
    this.closedShape,
    this.errorBuilder,
    this.loadingBuilder,
    this.backgroundColor = Colors.black,
    this.height,
    this.width,
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.closeButton,
    this.pageIndicator,
    this.initialIndex = 0,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.buttonAlignment = Alignment.topRight,
    this.buttonPadding = const EdgeInsets.only(top: 20, right: 20),
    this.showIndicator = true,
    this.indicatorAlignment = Alignment.bottomCenter,
    this.indicatorTextStyle = const TextStyle(color: Colors.white),
    this.indicatorPadding = EdgeInsets.zero,
    this.headers,
    this.controller,
    super.key,
  })  : _imageType = _ImageType.file,
        _images = images;

  const CoreImageViewer.memory({
    required this.child,
    required List<Uint8List> images,
    this.verticalDragCloseThreshold = VerticalDragCloseThreshold.medium,
    this.openShape,
    this.closedShape,
    this.errorBuilder,
    this.loadingBuilder,
    this.backgroundColor = Colors.black,
    this.height,
    this.width,
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.closeButton,
    this.pageIndicator,
    this.initialIndex = 0,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.buttonAlignment = Alignment.topRight,
    this.buttonPadding = const EdgeInsets.only(top: 20, right: 20),
    this.showIndicator = true,
    this.indicatorAlignment = Alignment.bottomCenter,
    this.indicatorTextStyle = const TextStyle(color: Colors.white),
    this.indicatorPadding = EdgeInsets.zero,
    this.headers,
    this.controller,
    super.key,
  })  : _imageType = _ImageType.memory,
        _images = images;

  final Widget child;
  final List<dynamic> _images;
  final VerticalDragCloseThreshold verticalDragCloseThreshold;
  final ShapeBorder? openShape;
  final ShapeBorder? closedShape;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final Color backgroundColor;
  final double? height;
  final double? width;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;
  final PositionedBuilder? closeButton;
  final _PageIndicatorBuilder? pageIndicator;
  final int initialIndex;
  final Duration? transitionDuration;
  final Alignment buttonAlignment;
  final EdgeInsets buttonPadding;
  final bool showIndicator;
  final Alignment indicatorAlignment;
  final TextStyle indicatorTextStyle;
  final EdgeInsets indicatorPadding;
  final Map<String, String>? headers;
  final _ImageType _imageType;
  final CoreImageController? controller;

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) return child;
    return _AnimationWrapper<int>(
      openBuilder: (_, __) {
        return _CoreImageViewer(
          key: key,
          backgroundColor: backgroundColor,
          verticalDragCloseThreshold: verticalDragCloseThreshold,
          images: _images,
          imageType: _imageType,
          initialIndex: initialIndex,
          headers: headers,
          buttonAlignment: buttonAlignment,
          buttonPadding: buttonPadding,
          indicatorAlignment: indicatorAlignment,
          indicatorPadding: indicatorPadding,
          indicatorTextStyle: indicatorTextStyle,
          cacheHeight: cacheHeight,
          cacheWidth: cacheWidth,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          fit: fit,
          height: height,
          closeButton: closeButton,
          pageIndicator: pageIndicator,
          showIndicator: showIndicator,
          width: width,
        );
      },
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        controller?._init(openContainer);
        return GestureDetector(
          onTap: openContainer,
          child: child,
        );
      },
      closedShape: closedShape,
      openShape: openShape,
      transitionDuration: transitionDuration,
    );
  }
}

class _CoreImageViewer extends StatefulWidget {
  const _CoreImageViewer({
    required this.images,
    required this.imageType,
    required this.indicatorAlignment,
    required this.indicatorPadding,
    required this.indicatorTextStyle,
    required this.buttonPadding,
    required this.buttonAlignment,
    required this.initialIndex,
    required this.showIndicator,
    required this.verticalDragCloseThreshold,
    required this.backgroundColor,
    this.errorBuilder,
    this.loadingBuilder,
    this.height,
    this.width,
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.headers,
    this.pageIndicator,
    this.closeButton,
    super.key,
  });

  final List<dynamic> images;
  final _ImageType imageType;
  final int initialIndex;
  final Color backgroundColor;
  final VerticalDragCloseThreshold verticalDragCloseThreshold;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final double? height;
  final double? width;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;
  final Alignment buttonAlignment;
  final EdgeInsets buttonPadding;
  final PositionedBuilder? closeButton;
  final bool showIndicator;
  final Alignment indicatorAlignment;
  final TextStyle indicatorTextStyle;
  final EdgeInsets indicatorPadding;
  final _PageIndicatorBuilder? pageIndicator;
  final Map<String, String>? headers;

  @override
  State<_CoreImageViewer> createState() => _CoreImageViewerState();
}

class _CoreImageViewerState extends State<_CoreImageViewer> {
  double _initialPositionY = 0;
  double _currentPositionY = 0;
  double _positionYDelta = 0;
  double _opacity = 1;
  Duration _animationDuration = Duration.zero;
  late final PageController _pageController;
  late int _activePage;
  late TapDownDetails _doubleTapDetails;
  final TransformationController _transformationController = TransformationController();
  final double _minScale = 1;
  final double _maxScale = 5;
  _ScaleLevel _scaleLevel = _ScaleLevel.off;
  final _routeDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _activePage = widget.initialIndex;
    _transformationController.addListener(() {
      final isScale = _transformationController.value.getMaxScaleOnAxis() > 1;
      if (isScale != _isScale) {
        setState(() {
          _isScale = isScale;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _transformationController.dispose();
  }

  bool _isScale = false;

  @override
  Widget build(BuildContext context) {
    final horizontalPosition = max(_positionYDelta, -_positionYDelta) / 15;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            physics: _isScale ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
            onPageChanged: _onPageChange,
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final item = widget.images[index];
              return Container(
                key: Key('image_$index'),
                color: widget.backgroundColor.withOpacity(_opacity),
                constraints: BoxConstraints.expand(
                  height: context.height,
                  width: context.width,
                ),
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      key: Key('animated_positioned_$index'),
                      duration: _animationDuration,
                      curve: Curves.bounceInOut,
                      top: 0 + _positionYDelta,
                      bottom: 0 - _positionYDelta,
                      left: horizontalPosition,
                      right: horizontalPosition,
                      child: GestureDetector(
                        onDoubleTapDown: _onDoubleTapDown,
                        onDoubleTap: _onDoubleTap,
                        child: InteractiveViewer(
                          key: const Key('core_image_viewer'),
                          transformationController: _transformationController,
                          minScale: _minScale,
                          maxScale: _maxScale,
                          panEnabled: _isScale,
                          child: _KeyMotionGestureDetector(
                            onStart: _onDragStart,
                            onUpdate: _onDragUpdate,
                            onEnd: _onDragEnd,
                            child: _getViewWidgetByImageType(item),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          _ImageViewerIndicator(
            showIndicator: widget.showIndicator,
            indicatorAlignment: widget.indicatorAlignment,
            indicatorPadding: widget.indicatorPadding,
            indicatorTextStyle: widget.indicatorTextStyle,
            pageIndicator: widget.pageIndicator,
            activePage: _activePage,
            totalPages: widget.images.length,
          ),
          _ImageViewerCloseButton(
            buttonAlignment: widget.buttonAlignment,
            buttonPadding: widget.buttonPadding,
            closeButton: widget.closeButton,
          ),
        ],
      ),
    );
  }

  Widget _getViewWidgetByImageType(dynamic image) {
    return switch (widget.imageType) {
      _ImageType.memory => Image.memory(
          image as Uint8List,
          errorBuilder: widget.errorBuilder,
          height: widget.height,
          width: widget.width,
          cacheWidth: widget.cacheWidth,
          cacheHeight: widget.cacheHeight,
          fit: widget.fit,
        ),
      _ImageType.file => Image.file(
          image as File,
          errorBuilder: widget.errorBuilder,
          height: widget.height,
          width: widget.width,
          cacheWidth: widget.cacheWidth,
          cacheHeight: widget.cacheHeight,
          fit: widget.fit,
        ),
      _ImageType.asset => Image.asset(
          image as String,
          errorBuilder: widget.errorBuilder,
          height: widget.height,
          width: widget.width,
          cacheWidth: widget.cacheWidth,
          cacheHeight: widget.cacheHeight,
          fit: widget.fit,
        ),
      _ImageType.network => Image.network(
          image as String,
          errorBuilder: widget.errorBuilder,
          height: widget.height,
          width: widget.width,
          cacheWidth: widget.cacheWidth,
          cacheHeight: widget.cacheHeight,
          fit: widget.fit,
          loadingBuilder: widget.loadingBuilder,
          headers: widget.headers,
        ),
    };
  }

  void _onPageChange(int index) {
    setState(() {
      _activePage = index;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _onDoubleTapDown(TapDownDetails details) {
    setState(() {
      _doubleTapDetails = details;
    });
  }

  void _onDoubleTap() {
    setState(() {
      final position = _doubleTapDetails.localPosition;
      if (_isScale && _scaleLevel == _ScaleLevel.off) {
        _transformationController.value = Matrix4.identity();
        _scaleLevel = _ScaleLevel.off;
        return;
      }
      switch (_scaleLevel) {
        case _ScaleLevel.off:
          _transformationController.value = Matrix4.identity()
            ..translate(-position.dx, -position.dy)
            ..scale(2.0);
          _scaleLevel = _ScaleLevel.x2;
        case _ScaleLevel.x2:
          _transformationController.value = Matrix4.identity()
            ..translate(-position.dx * 2, -position.dy * 2)
            ..scale(3.0);
          _scaleLevel = _ScaleLevel.x3;
        case _ScaleLevel.x3:
          _transformationController.value = Matrix4.identity();
          _scaleLevel = _ScaleLevel.off;
      }
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isScale) return;
    setState(() {
      _currentPositionY = details.globalPosition.dy;
      _positionYDelta = _currentPositionY - _initialPositionY;
      setOpacity();
    });
  }

  void _onDragStart(DragStartDetails details) {
    if (_isScale) return;
    setState(() {
      _initialPositionY = details.globalPosition.dy;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isScale) return;
    if (_positionYDelta > verticalDragCloseThreshold || _positionYDelta < -verticalDragCloseThreshold) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _animationDuration = _routeDuration;
        _opacity = 1;
        _positionYDelta = 0;
      });

      _animationDuration.delay(() {
        setState(() {
          _animationDuration = Duration.zero;
        });
      });
    }
  }

  double get verticalDragCloseThreshold {
    return switch (widget.verticalDragCloseThreshold) {
      VerticalDragCloseThreshold.low => 50,
      VerticalDragCloseThreshold.medium => 150,
      VerticalDragCloseThreshold.high => 250,
    };
  }

  void setOpacity() {
    final tmp = _positionYDelta < 0 ? 1 - ((_positionYDelta / 1000) * -1) : 1 - (_positionYDelta / 1000);
    _opacity = tmp.clamp(0, 1);
  }
}

class _ImageViewerIndicator extends StatelessWidget {
  const _ImageViewerIndicator({
    required this.indicatorAlignment,
    required this.indicatorPadding,
    required this.indicatorTextStyle,
    required this.pageIndicator,
    required this.showIndicator,
    required this.activePage,
    required this.totalPages,
  });

  final bool showIndicator;
  final _PageIndicatorBuilder? pageIndicator;
  final Alignment indicatorAlignment;
  final EdgeInsets indicatorPadding;
  final TextStyle indicatorTextStyle;
  final int activePage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    if (!showIndicator) return emptyBox;
    if (pageIndicator.isNotNull) return pageIndicator!(context, activePage, totalPages);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: indicatorPadding,
          child: Text(
            '${activePage + 1}/$totalPages',
            style: indicatorTextStyle,
          ),
        ),
      ),
    );
  }
}

class _ImageViewerCloseButton extends StatelessWidget {
  const _ImageViewerCloseButton({
    required this.buttonAlignment,
    required this.buttonPadding,
    required this.closeButton,
  });

  final Alignment buttonAlignment;
  final EdgeInsets buttonPadding;
  final PositionedBuilder? closeButton;

  @override
  Widget build(BuildContext context) {
    if (closeButton.isNotNull) return closeButton!(context);

    return Align(
      alignment: buttonAlignment,
      child: Padding(
        padding: buttonPadding,
        child: SafeArea(
          child: Material(
            color: const Color(0xff222222),
            shape: const CircleBorder(),
            child: CoreButton(
              onPressed: Navigator.of(context).pop,
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: const Center(
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimationWrapper<T extends int> extends StatelessWidget {
  const _AnimationWrapper({
    required this.openBuilder,
    required this.closedBuilder,
    super.key,
    this.transitionDuration,
    this.openShape,
    this.closedShape,
  });

  final OpenContainerBuilder<T> openBuilder;
  final CloseContainerBuilder closedBuilder;
  final Duration? transitionDuration;
  final ShapeBorder? openShape;
  final ShapeBorder? closedShape;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<T>(
      closedElevation: 0,
      openElevation: 0,
      openBuilder: openBuilder,
      closedBuilder: closedBuilder,
      openShape: openShape ?? const RoundedRectangleBorder(),
      closedShape: closedShape ?? const RoundedRectangleBorder(),
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 350),
      tappable: false,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      middleColor: Colors.transparent,
    );
  }
}

class _KeyMotionGestureDetector extends StatelessWidget {
  const _KeyMotionGestureDetector({
    required this.child,
    this.onStart,
    this.onUpdate,
    this.onEnd,
  });

  final Widget child;
  final GestureDragStartCallback? onStart;
  final GestureDragUpdateCallback? onUpdate;
  final GestureDragEndCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer()
            ..onStart = onStart
            ..onUpdate = onUpdate
            ..onEnd = onEnd,
          (instance) {},
        ),
      },
      child: child,
    );
  }
}
