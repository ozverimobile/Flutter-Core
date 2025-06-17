part of 'popup_manager_impl.dart';

/// A [DialogRoute] shows [CircularProgressIndicator] in center
final class LoaderRoute extends DialogRoute<void> implements ICorePopupController {
  LoaderRoute._({
    required super.context,
    required super.builder,
    required this.onCompleted,
    this.id,
  }) : super(barrierDismissible: false);

  @override
  final String? id;
  @override
  final Completer<void> completer = Completer<void>();

  @override
  void didComplete(void result) {
    onCompleted(this);
    if (!completer.isCompleted) completer.complete(null);
    super.didComplete(result);
  }

  @override
  void Function(ICorePopupController controller) onCompleted;
}

/// A [ModalBottomSheetRoute] shows a modal bottom sheet
final class BSheetRoute<T> extends ModalBottomSheetRoute<T> implements ICorePopupController {
  BSheetRoute._({
    required super.builder,
    required super.isScrollControlled,
    required this.onCompleted,
    this.id,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.backgroundColor,
    super.elevation,
    super.shape,
    super.clipBehavior,
    super.constraints,
    super.modalBarrierColor,
    super.isDismissible = true,
    super.enableDrag = true,
    super.showDragHandle,
    super.scrollControlDisabledMaxHeightRatio,
    super.settings,
    super.transitionAnimationController,
    super.anchorPoint,
    super.useSafeArea = false,
  });

  @override
  final String? id;
  @override
  final Completer<T?> completer = Completer<T?>();

  @override
  void Function(ICorePopupController p1) onCompleted;

  @override
  void didComplete(T? result) {
    onCompleted(this);
    if (!completer.isCompleted) completer.complete(result);
    super.didComplete(result);
  }
}

/// A [CupertinoSheetRoute] shows an iOS style bottom sheet
final class CSheetRoute<T> extends CupertinoSheetRoute<T> implements ICorePopupController {
  CSheetRoute._({
    required super.builder,
    required this.onCompleted,
    this.id,
    super.enableDrag,
    super.settings,
  });

  @override
  final String? id;
  @override
  final Completer<T?> completer = Completer<T?>();

  @override
  void Function(ICorePopupController controller) onCompleted;

  @override
  void didComplete(T? result) {
    onCompleted(this);
    if (!completer.isCompleted) completer.complete(result);
    super.didComplete(result);
  }
}

/// A [DialogRoute] shows dialog
final class DRoute<T> extends DialogRoute<T> implements ICorePopupController {
  DRoute._({
    required super.context,
    required super.builder,
    required this.onCompleted,
    this.id,
    super.themes,
    super.barrierColor,
    super.barrierDismissible,
    super.barrierLabel,
    super.useSafeArea,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
  });

  @override
  void Function(ICorePopupController) onCompleted;

  @override
  final String? id;

  @override
  final Completer<T?> completer = Completer<T?>();

  @override
  void didComplete(T? result) {
    onCompleted(this);
    if (!completer.isCompleted) completer.complete(result);
    super.didComplete(result);
  }
}

/// A [CupertinoDialogRoute] shows dialog
final class CPDialogRoute<T> extends CupertinoDialogRoute<T> implements ICorePopupController {
  CPDialogRoute._({
    required super.context,
    required super.builder,
    required this.onCompleted,
    this.id,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    super.settings,
    super.anchorPoint,
  });

  @override
  final String? id;
  @override
  final Completer<T?> completer = Completer<T?>();

  @override
  void Function(ICorePopupController controller) onCompleted;

  @override
  void didComplete(T? result) {
    onCompleted(this);
    if (!completer.isCompleted) completer.complete(result);
    super.didComplete(result);
  }
}

/// A [CupertinoModalPopupRoute] shows modal popup
final class CPModalPopupRoute<T> extends CupertinoModalPopupRoute<T> implements ICorePopupController {
  CPModalPopupRoute._({
    required super.builder,
    required this.onCompleted,
    this.id,
    super.filter,
    super.barrierColor,
    super.barrierDismissible,
    super.semanticsDismissible,
    super.settings,
    super.anchorPoint,
  });

  @override
  final String? id;
  @override
  final Completer<T?> completer = Completer<T?>();

  @override
  void Function(ICorePopupController controller) onCompleted;

  @override
  void didComplete(T? result) {
    onCompleted(this);
    if (!completer.isCompleted) completer.complete(result);
    super.didComplete(result);
  }
}

/// Interface provides [id] to popups
abstract interface class ICorePopupController {
  String? get id;

  Completer<dynamic> get completer;

  void Function(ICorePopupController) get onCompleted;
}
