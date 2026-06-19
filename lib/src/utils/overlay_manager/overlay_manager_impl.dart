import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

abstract interface class IOverlayManager {
  void showToast({Key? key, String? title, String? message, TextStyle? titleStyle, TextStyle? messageStyle, int? messageMaxLines, ToastPosition toastPosition = ToastPosition.bottom, Color? backgroundColor, Color? shadowColor, DismissDirection? dismissDirection, Widget? leading, Duration? toastDuration, Duration? animationDuration, Duration? reverseAnimationDuration, Widget? child});

  void showOverlay({required PositionedBuilder builder, required String id});

  void closeOverlay({required String id});

  void closeLatestOverlay();

  void closeAllOverlays();

  void closeAllToasts({bool immediate = false});

  bool isOverlayOpen({required String id});
}

/// Advanced [OverlayManager] for showing toasts or custom overlays.
@immutable
class OverlayManager implements IOverlayManager {
  OverlayManager({required GlobalKey<NavigatorState> navigatorKey}) : _key = navigatorKey;

  /// [NavigatorState] key of desired [Navigator]
  final GlobalKey<NavigatorState> _key;

  OverlayState get _overlayState {
    final ovState = _key.currentState?.overlay;
    assert(ovState.isNotNull, 'Tried to show toast but overlayState was null. Key was :$_key');
    return ovState!;
  }

  /// Holds active overlays and controllers
  final _toastInfoList = <ToastOverlayInfo>[];

  /// Holds active overlay entries
  final _overlayEntryInfoList = <OverlayEntryInfo>[];

  /// Default toast duration
  final _defaultToastDuration = const Duration(milliseconds: 2000);

  /// Default toast slide animation duration
  final _slideAnimationDuration = const Duration(milliseconds: 500);

  /// Shows a highly customizable toast with animation
  @override
  void showToast({
    Key? key,
    String? title,
    String? message,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    int? messageMaxLines,
    ToastPosition toastPosition = ToastPosition.bottom,
    Color? backgroundColor,
    Color? shadowColor,
    DismissDirection? dismissDirection,
    Widget? leading,
    Duration? toastDuration,
    Duration? animationDuration,
    Duration? reverseAnimationDuration,
    Widget? child,
  }) {
    _presentToast(
      key: key,
      title: title,
      message: message,
      leading: leading,
      toastDuration: toastDuration,
      animationDuration: animationDuration,
      reverseAnimationDuration: reverseAnimationDuration,
      toastPosition: toastPosition,
      dismissDirection: dismissDirection,
      child: child,
      backgroundColor: backgroundColor,
      messageStyle: messageStyle,
      messageMaxLines: messageMaxLines,
      shadowColor: shadowColor,
      titleStyle: titleStyle,
    );
  }

  /// Inserts toast into overlay state entries list and schedules for removal after [toastDuration]
  ///
  /// This is the function actually shows the toast
  void _presentToast({
    required ToastPosition toastPosition,
    Key? key,
    String? title,
    String? message,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    Duration? toastDuration,
    Duration? animationDuration,
    Duration? reverseAnimationDuration,
    int? messageMaxLines,
    DismissDirection? dismissDirection,
    Widget? leading,
    Widget? child,
    Color? backgroundColor,
    Color? shadowColor,
  }) {
    if (child.isNotNull && (leading.isNotNull || title.isNotNull || message.isNotNull)) {
      throw MisUsageToastError('If child is specified; leading, title and message must be null');
    }

    final slideAnimationController = AnimationController(
      vsync: _overlayState,
      duration: animationDuration ?? _slideAnimationDuration,
      reverseDuration: reverseAnimationDuration ?? _slideAnimationDuration,
    );
    late final OverlayEntry overlayEntry;
    var isPendingRemoval = true;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return CoreToast(
          key: key,
          slideAnimationController: slideAnimationController,
          toastPosition: toastPosition,
          leading: leading,
          title: title,
          message: message,
          messageMaxLines: messageMaxLines,
          dismissDirection: dismissDirection,
          onDismissed: (direction) {
            if (isPendingRemoval) {
              isPendingRemoval = false;
              _toastInfoList.remove((entry: overlayEntry, slideAnimationController: slideAnimationController));
              overlayEntry
                ..remove()
                ..dispose();
              slideAnimationController.dispose();
            }
          },
          backgroundColor: backgroundColor,
          shadowColor: shadowColor,
          titleStyle: titleStyle,
          messageStyle: messageStyle,
          child: child,
        );
      },
    );

    _insertToast(slideAnimationController, overlayEntry, _overlayState);
    _scheduleToastForRemoval(toastDuration ?? _defaultToastDuration, slideAnimationController, overlayEntry, _overlayState);
  }

  /// Inserts toast into overlay entries and forwards the animation
  void _insertToast(AnimationController slideAnimationController, OverlayEntry entry, OverlayState overlayState) {
    final overlayInfo = (entry: entry, slideAnimationController: slideAnimationController);
    _toastInfoList.insert(0, overlayInfo);
    overlayState.insert(entry);
    slideAnimationController.forward();
  }

  /// Reverses the animation after [schedule] and removes toast when animation is completed
  void _scheduleToastForRemoval(Duration schedule, AnimationController slideAnimationController, OverlayEntry entry, OverlayState overlayState) {
    schedule.delay(() {
      final elementIndex = _toastInfoList.indexOf((entry: entry, slideAnimationController: slideAnimationController));
      if (elementIndex == -1) return;
      final overlayInfo = _toastInfoList[elementIndex];
      overlayInfo.slideAnimationController.reverse().then((_) {
        overlayInfo.entry
          ..remove()
          ..dispose();
        overlayInfo.slideAnimationController.dispose();
        _toastInfoList.remove(overlayInfo);
      });
    });
  }

  /// Closes all open toasts
  ///
  /// If [immediate] is true, closes all toasts immediately
  /// Otherwise, closes all toasts with animation
  @override
  void closeAllToasts({bool immediate = false}) {
    if (immediate) {
      for (final toastInfo in _toastInfoList) {
        toastInfo.entry
          ..remove()
          ..dispose();
        toastInfo.slideAnimationController.dispose();
      }
      _toastInfoList.clear();
    } else {
      for (final toastInfo in _toastInfoList) {
        toastInfo.slideAnimationController.reverse().then((_) {
          toastInfo.entry
            ..remove()
            ..dispose();
          toastInfo.slideAnimationController.dispose();
          _toastInfoList.remove(toastInfo);
        });
      }
    }
  }

  /// Shows an overlay with [builder] and [id]
  @override
  void showOverlay({required PositionedBuilder builder, required String id}) {
    final entry = OverlayEntry(builder: builder);
    _overlayState.insert(entry);
    _overlayEntryInfoList.add((entry: entry, id: id));
  }

  /// Closes an overlay with [id]
  @override
  void closeOverlay({required String id}) {
    final index = _overlayEntryInfoList.indexWhere((element) => element.id == id);
    assert(index != -1, 'No overlay found with id: $id');
    final removed = _overlayEntryInfoList.removeAt(index);
    removed.entry
      ..remove()
      ..dispose();
  }

  /// Closes the latest overlay
  @override
  void closeLatestOverlay() {
    assert(_overlayEntryInfoList.isNotEmpty, 'No overlay to close');
    final removed = _overlayEntryInfoList.removeLast();
    removed.entry
      ..remove()
      ..dispose();
  }

  /// Closes all open overlays
  @override
  void closeAllOverlays() {
    for (final overlayInfo in _overlayEntryInfoList) {
      overlayInfo.entry
        ..remove()
        ..dispose();
    }
    _overlayEntryInfoList.clear();
  }

  /// Checks if an overlay with [id] is open
  @override
  bool isOverlayOpen({required String id}) {
    return _overlayEntryInfoList.any((element) => element.id == id);
  }
}

/// Error thrown when [OverlayManager] is misused
final class MisUsageToastError extends Error {
  MisUsageToastError(this.message);

  /// Explanation of the error
  final String message;

  @override
  String toString() {
    return 'MisUsageToastError: $message';
  }
}
