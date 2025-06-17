import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

part 'routes.dart';

abstract interface class IPopupManager {
  void showLoader({BuildContext? context, String? id, bool barrierDismissible, WidgetBuilder? widgetBuilder});

  Future<T?> showModalBottomSheet<T>({required WidgetBuilder builder, BuildContext? context, String? id, Color? backgroundColor, String? barrierLabel, double? elevation, ShapeBorder? shape, Clip? clipBehavior, BoxConstraints? constraints, Color? barrierColor, bool isScrollControlled, double scrollControlDisabledMaxHeightRatio, bool isDismissible, bool enableDrag, bool? showDragHandle, bool useSafeArea, RouteSettings? routeSettings, AnimationController? transitionAnimationController, Offset? anchorPoint});

  Future<T?> showDialog<T>({required WidgetBuilder builder, BuildContext? context, String? id, bool barrierDismissible, Color? barrierColor, String? barrierLabel, bool useSafeArea, RouteSettings? routeSettings, Offset? anchorPoint, TraversalEdgeBehavior? traversalEdgeBehavior});

  Future<T?> showCupertinoDialog<T>({required WidgetBuilder builder, BuildContext? context, String? id, String? barrierLabel, bool barrierDismissible, RouteSettings? routeSettings, Offset? anchorPoint});

  Future<T?> showCupertinoModalPopup<T>({required WidgetBuilder builder, BuildContext? context, String? id, ImageFilter? filter, Color barrierColor, bool barrierDismissible, bool semanticsDismissible, RouteSettings? routeSettings, Offset? anchorPoint});

  Future<void> showAdaptiveInfoDialog({
    BuildContext? context,
    String? id,
    String? barrierLabel,
    Key? key,
    bool? barrierDismissible,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Color? barrierColor,
    bool useSafeArea,
    Widget? title,
    Widget? content,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry? iconPadding,
    EdgeInsetsGeometry? buttonPadding,
    EdgeInsets? insetPadding,
    AlignmentGeometry? alignment,
    Widget? icon,
    ShapeBorder? shape,
    double? elevation,
    Color? backgroundColor,
    Color? shadowColor,
    MainAxisAlignment? actionsAlignment,
    bool scrollable,
    ScrollController? actionScrollController,
    String? semanticLabel,
    OverflowBarAlignment? actionsOverflowAlignment,
    double? actionsOverflowButtonSpacing,
    VerticalDirection? actionsOverflowDirection,
    Clip clipBehavior,
    TextStyle? contentTextStyle,
    Color? iconColor,
    Curve insetAnimationCurve,
    Duration insetAnimationDuration,
    ScrollController? scrollController,
    Color? surfaceTintColor,
    TextStyle? titleTextStyle,
    String? okButtonLabel,
  });

  Future<T?> showDefaultAdaptiveAlertDialog<T>({
    BuildContext? context,
    String? id,
    String? barrierLabel,
    Key? key,
    bool? barrierDismissible,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Color? barrierColor,
    bool useSafeArea = true,
    Widget? title,
    Widget? content,
    bool reversedActions = false,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry? iconPadding,
    EdgeInsetsGeometry? buttonPadding,
    EdgeInsets? insetPadding,
    AlignmentGeometry? alignment,
    Widget? icon,
    ShapeBorder? shape,
    double? elevation,
    Color? backgroundColor,
    Color? shadowColor,
    MainAxisAlignment? actionsAlignment,
    bool scrollable = false,
    ScrollController? actionScrollController,
    String? semanticLabel,
    OverflowBarAlignment? actionsOverflowAlignment,
    double? actionsOverflowButtonSpacing,
    VerticalDirection? actionsOverflowDirection,
    Clip clipBehavior = Clip.none,
    TextStyle? contentTextStyle,
    Color? iconColor,
    Curve insetAnimationCurve = Curves.decelerate,
    Duration insetAnimationDuration = const Duration(milliseconds: 100),
    ScrollController? scrollController,
    Color? surfaceTintColor,
    TextStyle? titleTextStyle,
    String? okButtonLabel,
    String? cancelButtonLabel,
    VoidCallback? onOkButtonPressed,
    bool isDefaultOkButtonIOS = false,
    bool isDestructiveCancelButtonIOS = false,
    bool isDestuctiveOkButtonIOS = false,
  });

  Future<DateTime?> showAdaptiveDatePicker({
    required DateTime initialDateTime,
    required DateTime minimumDate,
    required DateTime maximumDate,
    BuildContext? context,
    AdaptiveDatePickerMode mode,
    String? id,
    DatePickerDateOrder? dateOrderIOS,
    int minimumYearIOS,
    int? maximumYearIOS,
    bool use24hFormatIOS,
    bool showDayOfWeekIOS,
    int minuteIntervalIOS,
    double itemExtentIOS,
    TextInputType? keyboardTypeAndroid,
    String? cancelTextAndroid,
    String? confirmTextAndroid,
    String? errorFormatTextAndroid,
    String? errorInvalidTextAndroid,
    String? fieldHintTextAndroid,
    String? fieldLabelTextAndroid,
    String? helpTextAndroid,
    String? hourLabelTextAndroid,
    String? minuteLabelTextAndroid,
    DatePickerMode initialCalendarModeAndroid,
    DatePickerEntryMode datePickerInitialEntryMode,
    TimePickerEntryMode timePickerInitialEntryMode,
    void Function(DatePickerEntryMode)? onDatePickerModeChangeAndroid,
    void Function(TimePickerEntryMode)? onEntryModeChangedAndroid,
    bool Function(DateTime)? selectableDayPredicateAndroid,
    Icon? switchToCalendarEntryModeIconAndroid,
    Icon? switchToInputEntryModeIconAndroid,
    Orientation? orientationAndroid,
  });

  Future<int?> showAdaptivePicker({required List<Widget> children, BuildContext? context, Widget? title, String? okButtonLabel, String? cancelButtonLabel});

  Future<void> showUpdateAvailableDialog({String? androidPackageName, String? iOSAppId, String? huaweiAppId, BuildContext? context, bool isForceUpdate = false, bool iosLaunchIntune = false, String? title, String? message});

  Future<String?> showAdaptiveInputDialog({BuildContext? context, String? title, String? message, String? initialValue, String? hintText, String? okButtonLabel, String? cancelButtonLabel, TextInputType? keyboardType, bool obscureText, bool autocorrect, bool enableSuggestions, bool enableInteractiveSelection, bool enableSuggestionsForced, bool enableInteractiveSelectionForced, bool enableAutoFocus, bool showCursor, bool showSelectionHandles, bool autofocus, bool readOnly, bool showClearButton, bool showSelectionToolbar});

  Future<ImageSourceType?> showImageSourcePicker({BuildContext? context});

  Future<void> showPatchInstalledBottomSheet({required bool isForce, BuildContext? context});
  Future<T?> showCupertinoBottomSheet<T>({required WidgetBuilder builder, BuildContext? context, String? id, bool enableDrag = true, RouteSettings? settings});

  void hidePopup<T>({String? id, T? result});

  void hideAllPopups();

  bool isPopupOpen({required String id});

  Future<AdaptiveAction?> showAdaptiveActionSheet({
    BuildContext? context,
    String? title,
    String? content,
    List<AdaptiveAction> actions = const [],
    String? cancelButtonLabelOnIos,
  });

  Future<T?> singleSelectableSearchSheet<T extends SelectableSearchMixin>({
    BuildContext? context,
    List<T> items = const [],
    T? selected,
    Widget Function(BuildContext context, Widget child)? builder,
    ShapeBorder? shape,
    bool showDragHandle = false,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    String? title,
    String emptyResultText = 'Sonuç bulunamadı',
    String searchHintText = 'Bir şeyler arayın...',
    double initialSize = 0.5,
    int titleMaxLine = 2,
    int subtitleMaxLine = 1,
    TextOverflow titleOverflow = TextOverflow.ellipsis,
    TextOverflow subtitleOverflow = TextOverflow.ellipsis,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    bool showItemCount = true,
  });
  Future<List<T>?> multiSelectableSearchSheet<T extends SelectableSearchMixin>({
    BuildContext? context,
    List<T> items = const [],
    List<T>? selectedItems,
    Widget Function(BuildContext context, Widget child)? builder,
    ShapeBorder? shape,
    bool showDragHandle = false,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    String? title,
    String emptyResultText = 'Sonuç bulunamadı',
    String searchHintText = 'Bir şeyler arayın...',
    double initialSize = 0.5,
    int titleMaxLine = 2,
    int subtitleMaxLine = 1,
    TextOverflow titleOverflow = TextOverflow.ellipsis,
    TextOverflow subtitleOverflow = TextOverflow.ellipsis,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    bool showItemCount = true,
  });
}

/// A [PopupManager] manages all popups
class PopupManager implements IPopupManager {
  PopupManager({required GlobalKey<NavigatorState> navigatorKey}) : _navigatorKey = navigatorKey;
  final GlobalKey<NavigatorState> _navigatorKey;

  NavigatorState get _navigator {
    final state = _navigatorKey.currentState;
    assert(state.isNotNull, 'Navigator with provided key: $_navigatorKey was not found in the widget tree');
    return state!;
  }

  final _popupRoutes = <ICorePopupController>[];

  static const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

  BuildContext get _navigatorContext => _navigator.context;

  /// Shows loader dialog
  /// Provide [id] id if you have multiple loaders and want to close a specific one
  @override
  void showLoader({
    BuildContext? context,
    String? id,
    bool barrierDismissible = false,
    WidgetBuilder? widgetBuilder,
  }) {
    assert(
      id == null || _popupRoutes.where((element) => element.id == id).isEmpty,
      'There is already a loader showing with id: $id',
    );

    final route = LoaderRoute._(
      id: id,
      context: context ?? _navigatorContext,
      builder: widgetBuilder ??
          (BuildContext context) => switch (context.theme.platform) {
                TargetPlatform.iOS || TargetPlatform.macOS => Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CupertinoActivityIndicator(),
                    ),
                  ),
                _ => PopScope(
                    canPop: false,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
              },
      onCompleted: _onCompleted,
    );

    _popupRoutes.add(route);
    _navigator.push(route);
  }

  /// Shows cupertino bottom sheet
  @override
  Future<T?> showCupertinoBottomSheet<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    String? id,
    bool enableDrag = true,
    RouteSettings? settings,
  }) {
    assert(
      id == null || _popupRoutes.where((element) => element.id == id).isEmpty,
      'There is already a cupertino sheet showing with id: $id',
    );
    final route = CSheetRoute<T>._(
      builder: builder,
      onCompleted: _onCompleted,
      id: id,
      enableDrag: enableDrag,
      settings: settings,
    );

    _popupRoutes.add(route);
    _navigator.push(route);
    return route.completer.future;
  }

  /// Shows modal bottom sheet
  @override
  Future<T?> showModalBottomSheet<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    String? id,
    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    double scrollControlDisabledMaxHeightRatio = _defaultScrollControlDisabledMaxHeightRatio,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) {
    assert(
      id == null || _popupRoutes.where((element) => element.id == id).isEmpty,
      'There is already a loader showing with id: $id',
    );

    assert(debugCheckHasMediaQuery(context ?? _navigatorContext), 'No MediaQuery widget found.');
    assert(debugCheckHasMaterialLocalizations(context ?? _navigatorContext), 'No MaterialLocalizations widget found.');

    final localizations = MaterialLocalizations.of(context ?? _navigatorContext);

    final route = BSheetRoute<T>._(
      id: id,
      builder: builder,
      capturedThemes: InheritedTheme.capture(from: context ?? _navigatorContext, to: _navigatorContext),
      isScrollControlled: isScrollControlled,
      scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
      barrierLabel: barrierLabel ?? localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(localizations.bottomSheetLabel),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor ?? Theme.of(context ?? _navigatorContext).bottomSheetTheme.modalBarrierColor,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      settings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      useSafeArea: useSafeArea,
      onCompleted: _onCompleted,
    );

    _popupRoutes.add(route);
    _navigator.push(route);
    return route.completer.future;
  }

  /// Shows material dialog
  @override
  Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    String? id,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    assert(
      id == null || _popupRoutes.where((element) => element.id == id).isEmpty,
      'There is already a loader showing with id: $id',
    );

    assert(debugCheckHasMaterialLocalizations(context ?? _navigatorContext), 'No MaterialLocalizations widget found.');

    final localizations = MaterialLocalizations.of(context ?? _navigatorContext);

    final route = DRoute<T>._(
      id: id,
      builder: builder,
      context: context ?? _navigatorContext,
      themes: InheritedTheme.capture(from: context ?? _navigatorContext, to: _navigatorContext),
      barrierColor: barrierColor ?? Theme.of(context ?? _navigatorContext).dialogTheme.barrierColor ?? Colors.black54,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? localizations.dialogLabel,
      useSafeArea: useSafeArea,
      settings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
      onCompleted: _onCompleted,
    );

    _popupRoutes.add(route);
    _navigator.push(route);
    return route.completer.future;
  }

  /// Shows cupertino dialog
  @override
  Future<T?> showCupertinoDialog<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    String? id,
    String? barrierLabel,
    bool barrierDismissible = false,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    assert(
      id == null || _popupRoutes.where((element) => element.id == id).isEmpty,
      'There is already a loader showing with id: $id',
    );

    final route = CPDialogRoute<T>._(
      context: context ?? _navigatorContext,
      builder: builder,
      id: id,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context ?? _navigatorContext),
      settings: routeSettings,
      anchorPoint: anchorPoint,
      onCompleted: _onCompleted,
    );

    _popupRoutes.add(route);
    _navigator.push(route);
    return route.completer.future;
  }

  /// Shows adaptive info dialog
  @override
  Future<void> showAdaptiveInfoDialog({
    BuildContext? context,
    String? id,
    String? barrierLabel,
    Key? key,
    bool? barrierDismissible,
    bool closableWithBackButtonAndroid = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Color? barrierColor,
    bool useSafeArea = true,
    Widget? title,
    Widget? content,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry? iconPadding,
    EdgeInsetsGeometry? buttonPadding,
    EdgeInsets? insetPadding,
    AlignmentGeometry? alignment,
    Widget? icon,
    ShapeBorder? shape,
    double? elevation,
    Color? backgroundColor,
    Color? shadowColor,
    MainAxisAlignment? actionsAlignment,
    bool scrollable = false,
    ScrollController? actionScrollController,
    String? semanticLabel,
    OverflowBarAlignment? actionsOverflowAlignment,
    double? actionsOverflowButtonSpacing,
    VerticalDirection? actionsOverflowDirection,
    Clip clipBehavior = Clip.none,
    TextStyle? contentTextStyle,
    Color? iconColor,
    Curve insetAnimationCurve = Curves.decelerate,
    Duration insetAnimationDuration = const Duration(milliseconds: 100),
    ScrollController? scrollController,
    Color? surfaceTintColor,
    TextStyle? titleTextStyle,
    String? okButtonLabel,
    VoidCallback? onOkButtonPressed,
  }) {
    final routeId = id ?? UniqueKey().toString();
    Widget alertDialogBuilder(BuildContext context) {
      final iosButtons = [
        CupertinoDialogAction(
          onPressed: onOkButtonPressed ?? () => hidePopup<void>(id: routeId),
          child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
        ),
      ];

      final androidButtons = [
        FilledButton(
          onPressed: onOkButtonPressed ?? () => hidePopup<void>(id: routeId),
          child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
        ),
      ];
      final dialog = AlertDialog.adaptive(
        title: title,
        content: content,
        contentPadding: contentPadding,
        alignment: alignment,
        icon: icon,
        insetPadding: insetPadding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        key: key,
        shape: shape,
        titlePadding: titlePadding,
        actionsPadding: actionsPadding,
        elevation: elevation,
        backgroundColor: backgroundColor,
        shadowColor: shadowColor,
        iconPadding: iconPadding,
        buttonPadding: buttonPadding,
        actionsAlignment: actionsAlignment,
        scrollable: scrollable,
        actionScrollController: actionScrollController,
        semanticLabel: semanticLabel,
        actionsOverflowAlignment: actionsOverflowAlignment,
        actionsOverflowButtonSpacing: actionsOverflowButtonSpacing,
        actionsOverflowDirection: actionsOverflowDirection,
        clipBehavior: clipBehavior,
        contentTextStyle: contentTextStyle,
        iconColor: iconColor,
        insetAnimationCurve: insetAnimationCurve,
        insetAnimationDuration: insetAnimationDuration,
        scrollController: scrollController,
        surfaceTintColor: surfaceTintColor,
        titleTextStyle: titleTextStyle,
        actions: switch (context.theme.platform) {
          TargetPlatform.iOS || TargetPlatform.macOS => iosButtons,
          _ => androidButtons,
        },
      );
      if (closableWithBackButtonAndroid) {
        return dialog;
      } else {
        return PopScope(
          canPop: false,
          child: dialog,
        );
      }
    }

    return switch ((context ?? _navigatorContext).theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showCupertinoDialog<void>(
          context: context,
          builder: (context) => CupertinoTheme(
            data: const CupertinoThemeData(),
            child: alertDialogBuilder(context),
          ),
          id: routeId,
          barrierLabel: barrierLabel,
          barrierDismissible: barrierDismissible ?? false,
          routeSettings: routeSettings,
          anchorPoint: anchorPoint,
        ),
      _ => showDialog<void>(
          context: context,
          builder: alertDialogBuilder,
          id: routeId,
          barrierDismissible: barrierDismissible ?? true,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          useSafeArea: useSafeArea,
          routeSettings: routeSettings,
          anchorPoint: anchorPoint,
          traversalEdgeBehavior: traversalEdgeBehavior,
        ),
    };
  }

  /// Shows default adaptive alert dialog
  @override
  Future<T?> showDefaultAdaptiveAlertDialog<T>({
    BuildContext? context,
    String? id,
    String? barrierLabel,
    Key? key,
    bool? barrierDismissible,
    bool closableWithBackButtonAndroid = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Color? barrierColor,
    bool useSafeArea = true,
    Widget? title,
    Widget? content,
    bool reversedActions = false,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry? iconPadding,
    EdgeInsetsGeometry? buttonPadding,
    EdgeInsets? insetPadding,
    AlignmentGeometry? alignment,
    Widget? icon,
    ShapeBorder? shape,
    double? elevation,
    Color? backgroundColor,
    Color? shadowColor,
    MainAxisAlignment? actionsAlignment,
    bool scrollable = false,
    ScrollController? actionScrollController,
    String? semanticLabel,
    OverflowBarAlignment? actionsOverflowAlignment,
    double? actionsOverflowButtonSpacing,
    VerticalDirection? actionsOverflowDirection,
    Clip clipBehavior = Clip.none,
    TextStyle? contentTextStyle,
    Color? iconColor,
    Curve insetAnimationCurve = Curves.decelerate,
    Duration insetAnimationDuration = const Duration(milliseconds: 100),
    ScrollController? scrollController,
    Color? surfaceTintColor,
    TextStyle? titleTextStyle,
    String? okButtonLabel,
    String? cancelButtonLabel,
    VoidCallback? onOkButtonPressed,
    bool isDefaultOkButtonIOS = false,
    bool isDestructiveCancelButtonIOS = false,
    bool isDestuctiveOkButtonIOS = false,
  }) {
    Widget alertDialogBuilder(BuildContext context) {
      var iosButtons = [
        CupertinoDialogAction(
          onPressed: () {
            hidePopup<void>(id: id);
          },
          isDestructiveAction: isDestructiveCancelButtonIOS,
          child: Text(cancelButtonLabel ?? MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        CupertinoDialogAction(
          onPressed: onOkButtonPressed,
          isDefaultAction: isDefaultOkButtonIOS,
          isDestructiveAction: isDestuctiveOkButtonIOS,
          child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
        ),
      ];

      var androidButtons = [
        TextButton(
          onPressed: () {
            hidePopup<void>(id: id);
          },
          child: Text(cancelButtonLabel ?? MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: onOkButtonPressed,
          child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
        ),
      ];

      if (reversedActions) {
        iosButtons = iosButtons.reversed.toList();
        androidButtons = androidButtons.reversed.toList();
      }
      final dialog = AlertDialog.adaptive(
        title: title,
        content: content,
        contentPadding: contentPadding,
        alignment: alignment,
        icon: icon,
        insetPadding: insetPadding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        key: key,
        shape: shape,
        titlePadding: titlePadding,
        actionsPadding: actionsPadding,
        elevation: elevation,
        backgroundColor: backgroundColor,
        shadowColor: shadowColor,
        iconPadding: iconPadding,
        buttonPadding: buttonPadding,
        actionsAlignment: actionsAlignment,
        scrollable: scrollable,
        actionScrollController: actionScrollController,
        semanticLabel: semanticLabel,
        actionsOverflowAlignment: actionsOverflowAlignment,
        actionsOverflowButtonSpacing: actionsOverflowButtonSpacing,
        actionsOverflowDirection: actionsOverflowDirection,
        clipBehavior: clipBehavior,
        contentTextStyle: contentTextStyle,
        iconColor: iconColor,
        insetAnimationCurve: insetAnimationCurve,
        insetAnimationDuration: insetAnimationDuration,
        scrollController: scrollController,
        surfaceTintColor: surfaceTintColor,
        titleTextStyle: titleTextStyle,
        actions: switch (context.theme.platform) {
          TargetPlatform.iOS || TargetPlatform.macOS => iosButtons,
          _ => androidButtons,
        },
      );
      if (closableWithBackButtonAndroid) {
        return dialog;
      } else {
        return PopScope(
          canPop: false,
          child: dialog,
        );
      }
    }

    return switch ((context ?? _navigatorContext).theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showCupertinoDialog<T>(
          context: context,
          builder: (context) => CupertinoTheme(
            data: const CupertinoThemeData(),
            child: alertDialogBuilder(context),
          ),
          id: id,
          barrierLabel: barrierLabel,
          barrierDismissible: barrierDismissible ?? false,
          routeSettings: routeSettings,
          anchorPoint: anchorPoint,
        ),
      _ => showDialog<T>(
          context: context,
          builder: alertDialogBuilder,
          id: id,
          barrierDismissible: barrierDismissible ?? true,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          useSafeArea: useSafeArea,
          routeSettings: routeSettings,
          anchorPoint: anchorPoint,
          traversalEdgeBehavior: traversalEdgeBehavior,
        ),
    };
  }

  /// Shows adaptive date picker
  @override
  Future<DateTime?> showAdaptiveDatePicker({
    required DateTime initialDateTime,
    required DateTime minimumDate,
    required DateTime maximumDate,
    BuildContext? context,
    AdaptiveDatePickerMode mode = AdaptiveDatePickerMode.date,
    String? id,
    DatePickerDateOrder? dateOrderIOS,
    int minimumYearIOS = 1,
    int? maximumYearIOS,
    bool use24hFormatIOS = true,
    bool showDayOfWeekIOS = false,
    int minuteIntervalIOS = 1,
    double itemExtentIOS = 32,
    TextInputType? keyboardTypeAndroid,
    String? cancelTextAndroid,
    String? confirmTextAndroid,
    String? errorFormatTextAndroid,
    String? errorInvalidTextAndroid,
    String? fieldHintTextAndroid,
    String? fieldLabelTextAndroid,
    String? helpTextAndroid,
    String? hourLabelTextAndroid,
    String? minuteLabelTextAndroid,
    DatePickerMode initialCalendarModeAndroid = DatePickerMode.day,
    DatePickerEntryMode datePickerInitialEntryMode = DatePickerEntryMode.calendar,
    TimePickerEntryMode timePickerInitialEntryMode = TimePickerEntryMode.dial,
    void Function(DatePickerEntryMode)? onDatePickerModeChangeAndroid,
    void Function(TimePickerEntryMode)? onEntryModeChangedAndroid,
    bool Function(DateTime)? selectableDayPredicateAndroid,
    Icon? switchToCalendarEntryModeIconAndroid,
    Icon? switchToInputEntryModeIconAndroid,
    Orientation? orientationAndroid,
  }) {
    var selectedDate = initialDateTime;

    return switch ((context ?? _navigatorContext).theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showCupertinoModalPopup<DateTime>(
          context: context,
          id: id,
          builder: (context) => CupertinoTheme(
            data: CupertinoThemeData(brightness: context.theme.brightness),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.isLightMode ? const Color.fromARGB(255, 242, 242, 248) : const Color.fromARGB(255, 82, 81, 81),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CoreButton(
                      child: Text(
                        MaterialLocalizations.of(context).okButtonLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        hidePopup(id: id, result: selectedDate);
                      },
                    ),
                  ),
                ),
                Container(
                  color: context.isLightMode ? CupertinoColors.lightBackgroundGray : CupertinoColors.darkBackgroundGray,
                  height: 260,
                  child: SafeArea(
                    top: false,
                    child: CupertinoDatePicker(
                      onDateTimeChanged: (DateTime value) {
                        selectedDate = value;
                      },
                      dateOrder: dateOrderIOS,
                      initialDateTime: initialDateTime,
                      minimumDate: minimumDate,
                      maximumDate: maximumDate,
                      minimumYear: minimumYearIOS,
                      maximumYear: maximumYearIOS,
                      use24hFormat: use24hFormatIOS,
                      showDayOfWeek: showDayOfWeekIOS,
                      minuteInterval: minuteIntervalIOS,
                      mode: mode.toCupertinoDatePickerMode,
                      itemExtent: itemExtentIOS,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      _ => _showMaterialDateAndTimePickerConsecutively(
          context: context,
          mode: mode,
          id: id,
          initialDateTime: initialDateTime,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          initialCalendarModeAndroid: initialCalendarModeAndroid,
          datePickerInitialEntryModeAndroid: datePickerInitialEntryMode,
          timePickerInitialEntryModeAndroid: timePickerInitialEntryMode,
          helpTextAndroid: helpTextAndroid,
          hourLabelTextAndroid: hourLabelTextAndroid,
          minuteLabelTextAndroid: minuteLabelTextAndroid,
          errorFormatTextAndroid: errorFormatTextAndroid,
          errorInvalidTextAndroid: errorInvalidTextAndroid,
          fieldHintTextAndroid: fieldHintTextAndroid,
          fieldLabelTextAndroid: fieldLabelTextAndroid,
          confirmTextAndroid: confirmTextAndroid,
          cancelTextAndroid: cancelTextAndroid,
          keyboardTypeAndroid: keyboardTypeAndroid,
          onDatePickerModeChangeAndroid: onDatePickerModeChangeAndroid,
          selectableDayPredicateAndroid: selectableDayPredicateAndroid,
          switchToCalendarEntryModeIconAndroid: switchToCalendarEntryModeIconAndroid,
          switchToInputEntryModeIconAndroid: switchToInputEntryModeIconAndroid,
          orientationAndroid: orientationAndroid,
          onEntryModeChangedAndroid: onEntryModeChangedAndroid,
        ),
    };
  }

  /// Shows cupertino modal popup
  @override
  Future<T?> showCupertinoModalPopup<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    String? id,
    ImageFilter? filter,
    Color barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool semanticsDismissible = false,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    assert(
      id == null || _popupRoutes.where((element) => element.id == id).isEmpty,
      'There is already a loader showing with id: $id',
    );

    final route = CPModalPopupRoute<T>._(
      builder: builder,
      id: id,
      filter: filter,
      barrierColor: CupertinoDynamicColor.resolve(barrierColor, context ?? _navigatorContext),
      barrierDismissible: barrierDismissible,
      semanticsDismissible: semanticsDismissible,
      settings: routeSettings,
      anchorPoint: anchorPoint,
      onCompleted: _onCompleted,
    );
    _popupRoutes.add(route);

    _navigator.push(route);
    return route.completer.future;
  }

  /// In android shows date picker first then time picker if [mode] is [AdaptiveDatePickerMode.dateAndTime]
  ///
  /// In android shows date picker if [mode] is [AdaptiveDatePickerMode.date]
  ///
  /// In android shows time picker if [mode] is [AdaptiveDatePickerMode.time]
  Future<DateTime?> _showMaterialDateAndTimePickerConsecutively({
    required DateTime initialDateTime,
    required DateTime minimumDate,
    required DateTime maximumDate,
    required DatePickerMode initialCalendarModeAndroid,
    required DatePickerEntryMode datePickerInitialEntryModeAndroid,
    required TimePickerEntryMode timePickerInitialEntryModeAndroid,
    required AdaptiveDatePickerMode mode,
    String? id,
    BuildContext? context,
    TextInputType? keyboardTypeAndroid,
    String? cancelTextAndroid,
    String? confirmTextAndroid,
    String? errorFormatTextAndroid,
    String? errorInvalidTextAndroid,
    String? fieldHintTextAndroid,
    String? fieldLabelTextAndroid,
    String? helpTextAndroid,
    String? hourLabelTextAndroid,
    String? minuteLabelTextAndroid,
    void Function(DatePickerEntryMode)? onDatePickerModeChangeAndroid,
    void Function(TimePickerEntryMode)? onEntryModeChangedAndroid,
    bool Function(DateTime)? selectableDayPredicateAndroid,
    Icon? switchToCalendarEntryModeIconAndroid,
    Icon? switchToInputEntryModeIconAndroid,
    Orientation? orientationAndroid,
  }) async {
    switch (mode) {
      case AdaptiveDatePickerMode.date:
        return showDialog<DateTime>(
          context: context,
          id: id,
          builder: (context) => DatePickerDialog(
            firstDate: minimumDate,
            lastDate: maximumDate,
            currentDate: initialDateTime,
            initialDate: initialDateTime,
            keyboardType: keyboardTypeAndroid,
            cancelText: cancelTextAndroid,
            confirmText: confirmTextAndroid,
            errorFormatText: errorFormatTextAndroid,
            errorInvalidText: errorInvalidTextAndroid,
            fieldHintText: fieldHintTextAndroid,
            fieldLabelText: fieldLabelTextAndroid,
            helpText: helpTextAndroid,
            initialCalendarMode: initialCalendarModeAndroid,
            initialEntryMode: datePickerInitialEntryModeAndroid,
            onDatePickerModeChange: onDatePickerModeChangeAndroid,
            selectableDayPredicate: selectableDayPredicateAndroid,
            switchToCalendarEntryModeIcon: switchToCalendarEntryModeIconAndroid,
            switchToInputEntryModeIcon: switchToInputEntryModeIconAndroid,
          ),
        );
      case AdaptiveDatePickerMode.time:
        final time = await showDialog<TimeOfDay>(
          context: context,
          builder: (context) => TimePickerDialog(
            initialTime: TimeOfDay.fromDateTime(initialDateTime),
            orientation: orientationAndroid,
            initialEntryMode: timePickerInitialEntryModeAndroid,
            errorInvalidText: errorInvalidTextAndroid,
            helpText: helpTextAndroid,
            confirmText: confirmTextAndroid,
            cancelText: cancelTextAndroid,
            hourLabelText: hourLabelTextAndroid,
            minuteLabelText: minuteLabelTextAndroid,
            onEntryModeChanged: onEntryModeChangedAndroid,
          ),
        );
        if (time.isNull) return null;
        final now = DateTime.now();

        return DateTime(now.year, now.month, now.day, time!.hour, time.minute);

      case AdaptiveDatePickerMode.dateAndTime:
        final date = await showDialog<DateTime>(
          context: context,
          builder: (context) => DatePickerDialog(
            firstDate: minimumDate,
            lastDate: maximumDate,
            currentDate: initialDateTime,
            initialDate: initialDateTime,
            keyboardType: keyboardTypeAndroid,
            cancelText: cancelTextAndroid,
            confirmText: confirmTextAndroid,
            errorFormatText: errorFormatTextAndroid,
            errorInvalidText: errorInvalidTextAndroid,
            fieldHintText: fieldHintTextAndroid,
            fieldLabelText: fieldLabelTextAndroid,
            helpText: helpTextAndroid,
            initialCalendarMode: initialCalendarModeAndroid,
            initialEntryMode: datePickerInitialEntryModeAndroid,
            onDatePickerModeChange: onDatePickerModeChangeAndroid,
            selectableDayPredicate: selectableDayPredicateAndroid,
            switchToCalendarEntryModeIcon: switchToCalendarEntryModeIconAndroid,
            switchToInputEntryModeIcon: switchToInputEntryModeIconAndroid,
          ),
        );
        if (date.isNull || !(context ?? _navigatorContext).mounted) return null;
        final time = await showDialog<TimeOfDay>(
          context: context,
          builder: (context) => TimePickerDialog(
            initialTime: TimeOfDay.fromDateTime(initialDateTime),
            orientation: orientationAndroid,
            initialEntryMode: timePickerInitialEntryModeAndroid,
            errorInvalidText: errorInvalidTextAndroid,
            helpText: helpTextAndroid,
            confirmText: confirmTextAndroid,
            cancelText: cancelTextAndroid,
            hourLabelText: hourLabelTextAndroid,
            minuteLabelText: minuteLabelTextAndroid,
            onEntryModeChanged: onEntryModeChangedAndroid,
          ),
        );
        if (time.isNull) return null;
        return DateTime(date!.year, date.month, date.day, time!.hour, time.minute);
    }
  }

  @override
  Future<int?> showAdaptivePicker({
    required List<Widget> children,
    BuildContext? context,
    Widget? title,
    String? okButtonLabel,
    String? cancelButtonLabel,
    int? initialItemIndex,
    double androidHeight = 360,
    double iosHeight = 300,
  }) async {
    if (children.isEmpty) throw Exception('Children list of picker cannot be empty');
    final currentContext = context ?? _navigatorContext;
    final backgroundColor = currentContext.theme.brightness == Brightness.light ? Colors.white : CupertinoColors.darkBackgroundGray;
    var selectedItemIndex = initialItemIndex;
    final androidScrollController = ScrollController();
    final id = UniqueKey().toString();
    return switch (currentContext.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showModalBottomSheet<int>(
          id: id,
          context: currentContext,
          builder: (context) => CupertinoTheme(
            data: CupertinoThemeData(brightness: context.theme.brightness),
            child: Container(
              color: backgroundColor,
              height: iosHeight,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: title.isNotNull
                                ? DefaultTextStyle(
                                    style: context.textTheme.headlineSmall!,
                                    child: title!,
                                  )
                                : CupertinoButton(
                                    child: Text(cancelButtonLabel ?? MaterialLocalizations.of(context).cancelButtonLabel),
                                    onPressed: () {
                                      hidePopup<int>(id: id);
                                    },
                                  ),
                          ),
                        ),
                        CupertinoButton(
                          child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
                          onPressed: () {
                            hidePopup<int>(id: id, result: selectedItemIndex ?? 0);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SafeArea(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedItemIndex ?? 0),
                        itemExtent: 40,
                        onSelectedItemChanged: (value) => selectedItemIndex = value,
                        children: children
                            .map(
                              (element) => Center(
                                child: element,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      _ => showDialog(
          context: currentContext,
          id: id,
          builder: (context) => StatefulBuilder(
            builder: (context, updateCallback) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: androidHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title.isNotNull)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: DefaultTextStyle(
                                  style: context.textTheme.headlineSmall!,
                                  child: title!,
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Scrollbar(
                              interactive: true,
                              radius: context.theme.scrollbarTheme.radius ?? const Radius.circular(4),
                              controller: androidScrollController,
                              child: SingleChildScrollView(
                                controller: androidScrollController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int i = 0; i < children.length; i++)
                                      RadioListTile(
                                        title: children[i],
                                        value: selectedItemIndex,
                                        groupValue: i,
                                        onChanged: (value) {
                                          updateCallback(() {
                                            selectedItemIndex = i;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => hidePopup<int>(id: id),
                                child: Text(cancelButtonLabel ?? MaterialLocalizations.of(context).cancelButtonLabel),
                              ),
                              TextButton(
                                onPressed: selectedItemIndex.isNull ? null : () => hidePopup<int>(id: id, result: selectedItemIndex),
                                child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
    };
  }

  @override
  Future<String?> showAdaptiveInputDialog({
    BuildContext? context,
    String? title,
    String? message,
    String? initialValue,
    String? hintText,
    String? okButtonLabel,
    String? cancelButtonLabel,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool autocorrect = true,
    bool enableSuggestions = true,
    bool enableInteractiveSelection = true,
    bool enableSuggestionsForced = false,
    bool enableInteractiveSelectionForced = false,
    bool enableAutoFocus = false,
    bool showCursor = true,
    bool showSelectionHandles = true,
    bool autofocus = false,
    bool readOnly = false,
    bool showClearButton = false,
    bool showSelectionToolbar = false,
    TextStyle? style,
  }) async {
    final textController = TextEditingController(text: initialValue);
    final id = UniqueKey().toString();
    final currentContext = context ?? _navigatorContext;
    return switch (currentContext.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showCupertinoDialog<String>(
          context: context,
          id: id,
          builder: (context) => CupertinoAlertDialog(
            title: title.isNotNull ? Text(title!) : null,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.isNotNull)
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                  ),
                if (message.isNotNull) verticalBox12,
                CupertinoTextField(
                  controller: textController,
                  placeholder: hintText,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  autocorrect: autocorrect,
                  enableSuggestions: enableSuggestions,
                  enableInteractiveSelection: enableInteractiveSelection,
                  showCursor: showCursor,
                  autofocus: autofocus,
                  readOnly: readOnly,
                  style: style ?? context.textTheme.bodyLarge?.copyWith(color: context.theme.colorScheme.onSurface),
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => hidePopup<String>(id: id),
                child: Text(cancelButtonLabel ?? MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              CupertinoDialogAction(
                onPressed: () => hidePopup<String>(id: id, result: textController.text),
                child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
      _ => showDialog<String>(
          context: context,
          id: id,
          builder: (context) => AlertDialog(
            title: title.isNotNull ? Text(title!) : null,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isNotNull)
                  Text(
                    message!,
                  ),
                if (message.isNotNull) verticalBox12,
                TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: hintText,
                  ),
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  autocorrect: autocorrect,
                  enableSuggestions: enableSuggestions,
                  enableInteractiveSelection: enableInteractiveSelection,
                  showCursor: showCursor,
                  autofocus: autofocus,
                  readOnly: readOnly,
                  style: style ?? context.textTheme.bodyLarge?.copyWith(color: context.theme.colorScheme.onSurface),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => hidePopup<String>(id: id),
                child: Text(cancelButtonLabel ?? MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              FilledButton(
                onPressed: () => hidePopup<String>(id: id, result: textController.text),
                child: Text(okButtonLabel ?? MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
    };
  }

  @override
  Future<void> showUpdateAvailableDialog({
    String? androidPackageName,
    String? iOSAppId,
    String? huaweiAppId,
    BuildContext? context,
    bool isForceUpdate = false,
    bool iosLaunchIntune = false,
    String? title,
    String? message,
  }) async {
    const updateLabel = 'Güncelle';
    const dismissLabel = 'Daha sonra';
    const updateAvailableLabel = 'Güncelleme Mevcut';
    const forceUpdateMessage = 'Uygulamayı kullanabilmek için lütfen son sürüme güncelleyin.';
    const optionalUpdateMessage = 'Uygulamanın yeni sürümü mevcut. Güncellemek ister misiniz?';

    final id = UniqueKey().toString();
    final currentContext = context ?? _navigatorContext;

    return switch (currentContext.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showCupertinoDialog<void>(
          context: context,
          id: id,
          builder: (context) => CupertinoTheme(
            data: CupertinoThemeData(brightness: context.theme.brightness),
            child: CupertinoAlertDialog(
              title: Text(title ?? updateAvailableLabel),
              content: Text(
                message ?? (isForceUpdate ? forceUpdateMessage : optionalUpdateMessage),
              ),
              actions: isForceUpdate
                  ? [
                      CupertinoDialogAction(
                        onPressed: () => Core.updateApp(
                          androidPackageName: androidPackageName,
                          iOSAppId: iOSAppId,
                          huaweiAppId: huaweiAppId,
                          iosLaunchIntune: iosLaunchIntune,
                        ),
                        child: const Text(updateLabel),
                      ),
                    ]
                  : [
                      CupertinoDialogAction(
                        onPressed: () => hidePopup<void>(id: id),
                        isDestructiveAction: true,
                        child: const Text(dismissLabel),
                      ),
                      CupertinoDialogAction(
                        onPressed: () => Core.updateApp(
                          androidPackageName: androidPackageName,
                          iOSAppId: iOSAppId,
                          huaweiAppId: huaweiAppId,
                          iosLaunchIntune: iosLaunchIntune,
                        ),
                        isDefaultAction: true,
                        child: const Text(updateLabel),
                      ),
                    ],
            ),
          ),
        ),
      _ => showDialog<void>(
          context: context,
          id: id,
          barrierDismissible: !isForceUpdate,
          builder: (context) => PopScope(
            canPop: !isForceUpdate,
            child: AlertDialog(
              title: Text(title ?? updateAvailableLabel),
              content: Text(
                message ?? (isForceUpdate ? forceUpdateMessage : optionalUpdateMessage),
              ),
              actions: isForceUpdate
                  ? [
                      TextButton(
                        onPressed: () => Core.updateApp(
                          androidPackageName: androidPackageName,
                          iOSAppId: iOSAppId,
                          huaweiAppId: huaweiAppId,
                          iosLaunchIntune: iosLaunchIntune,
                        ),
                        child: const Text(updateLabel),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: () => hidePopup<void>(id: id),
                        child: const Text(dismissLabel),
                      ),
                      FilledButton(
                        onPressed: () => Core.updateApp(
                          androidPackageName: androidPackageName,
                          iOSAppId: iOSAppId,
                          huaweiAppId: huaweiAppId,
                          iosLaunchIntune: iosLaunchIntune,
                        ),
                        child: const Text(updateLabel),
                      ),
                    ],
            ),
          ),
        ),
    };
  }

  /// Shows image source options
  ///
  /// Dialog on Android and ActionSheet on iOS
  @override
  Future<ImageSourceType?> showImageSourcePicker({
    BuildContext? context,
  }) async {
    final id = UniqueKey().toString();
    final currentContext = context ?? _navigatorContext;
    return switch (currentContext.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showCupertinoModalPopup(
          context: context,
          id: id,
          builder: (context) => CupertinoTheme(
            data: CupertinoThemeData(brightness: context.theme.brightness),
            child: CupertinoActionSheet(
              title: const Text('Resim Seç'),
              message: const Text('Lütfen bir resim kaynağı seçin'),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => hidePopup<ImageSourceType>(id: id),
                isDestructiveAction: true,
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    hidePopup<ImageSourceType>(
                      id: id,
                      result: ImageSourceType.camera,
                    );
                  },
                  child: const Text('Kameradan Çek'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    hidePopup<ImageSourceType>(
                      id: id,
                      result: ImageSourceType.gallery,
                    );
                  },
                  child: const Text('Galeriden Seç'),
                ),
              ],
            ),
          ),
        ),
      _ => showDialog(
          context: context,
          id: id,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 18,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: DefaultTextStyle(
                            style: context.textTheme.headlineSmall!,
                            child: const Text('Resim Kaynağı Seç'),
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt_outlined),
                              title: const Text('Kameradan Çek'),
                              onTap: () {
                                hidePopup<ImageSourceType>(
                                  id: id,
                                  result: ImageSourceType.camera,
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_outlined),
                              title: const Text('Galeriden Seç'),
                              onTap: () {
                                hidePopup<ImageSourceType>(
                                  id: id,
                                  result: ImageSourceType.gallery,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: () => hidePopup<ImageSourceType>(id: id),
                            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    };
  }

  @override
  Future<void> showPatchInstalledBottomSheet({
    required bool isForce,
    BuildContext? context,
    String? title,
    String? message,
    String? closeButtonLabel,
    String? laterButtonLabel,
    VoidCallback? onPrimaryButtonPressed,
  }) async {
    final id = UniqueKey().toString();
    final currentContext = context ?? _navigatorContext;

    final title0 = title ?? (currentContext.locale.languageCode.toLowerCase() == 'tr' ? 'En güncel sürümü kullanmaya başlayabilirsiniz.' : 'You can start using the latest version.');
    final message0 = message ?? (currentContext.locale.languageCode.toLowerCase() == 'tr' ? 'Yeni özellikler ve hata düzeltmeleri ile uygulamanızı daha güvenli ve verimli kullanabilirsiniz. En son sürümü kullanmak için uygulamanızı yeniden başlatın.' : 'You can use your application more securely and efficiently with new features and bug fixes. Restart your application to use the latest version.');
    final closeButtonLabel0 = closeButtonLabel ?? (currentContext.locale.languageCode.toLowerCase() == 'tr' ? 'Uygulamayı Kapat' : 'Close Application');
    final laterButtonLabel0 = laterButtonLabel ?? (currentContext.locale.languageCode.toLowerCase() == 'tr' ? 'Daha Sonra' : 'Later');
    return showModalBottomSheet(
      context: currentContext,
      id: id,
      showDragHandle: false,
      isScrollControlled: true,
      isDismissible: !isForce,
      enableDrag: !isForce,
      builder: (context) => PopScope(
        canPop: !isForce,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (!isForce)
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filled(
                  icon: const Icon(Icons.close),
                  onPressed: () => hidePopup<void>(id: id),
                ),
              ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      verticalBox20,
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: context.theme.colorScheme.primary,
                          child: Icon(
                            Icons.downloading_rounded,
                            size: 36,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      verticalBox12,
                      CoreText.titleLarge(
                        title0,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      verticalBox12,
                      CoreText.bodyMedium(
                        message0,
                        textAlign: TextAlign.center,
                      ),
                      verticalBox32,
                      const Divider(),
                      verticalBox4,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        width: context.width,
                        height: 50,
                        child: CoreFilledButton(
                          onPressed: onPrimaryButtonPressed ?? () => exit(0),
                          borderRadius: BorderRadius.circular(10),
                          child: CoreText.bodyLarge(
                            closeButtonLabel0,
                            fontWeight: FontWeight.bold,
                            textColor: context.colorScheme.onError,
                          ),
                        ),
                      ),
                      if (!isForce) ...[
                        verticalBox8,
                        CoreTextButton(
                          child: CoreText.bodyLarge(
                            laterButtonLabel0,
                            fontWeight: FontWeight.w600,
                            textColor: context.colorScheme.primary,
                          ),
                          onPressed: () => hidePopup<void>(id: id),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows adaptive action sheet
  @override
  Future<AdaptiveAction?> showAdaptiveActionSheet({
    BuildContext? context,
    String? title,
    String? content,
    List<AdaptiveAction> actions = const [],
    String? cancelButtonLabelOnIos,
    bool showDragHandleOnAndroid = false,
    bool isScrollControlledOnAndroid = false,
    bool barrierDismissible = true,
    ShapeBorder? shapeOnAndroid,
  }) {
    final id = UniqueKey().toString();
    final currentContext = context ?? _navigatorContext;
    final androidTextTheme = context?.textTheme.bodyLarge;
    final androidIsDescructiveStyle = androidTextTheme?.copyWith(color: context?.theme.colorScheme.error);
    final androidIsDefaultStyle = androidTextTheme?.copyWith(fontWeight: FontWeight.bold);
    return switch (currentContext.theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => showCupertinoModalPopup(
          barrierDismissible: barrierDismissible,
          context: context,
          id: id,
          builder: (context) => CupertinoTheme(
            data: CupertinoThemeData(brightness: context.theme.brightness),
            child: CupertinoActionSheet(
              title: title == null ? null : Text(title),
              message: content == null ? null : Text(content),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => hidePopup<ImageSourceType>(id: id),
                isDestructiveAction: true,
                child: Text(cancelButtonLabelOnIos ?? MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              actions: List.generate(actions.length, (index) {
                final action = actions[index];
                return CupertinoActionSheetAction(
                  onPressed: () {
                    action.onPressed?.call();
                    hidePopup<AdaptiveAction>(id: id, result: action);
                  },
                  isDefaultAction: action.isDefaultAction,
                  isDestructiveAction: action.isDestructiveAction,
                  child: Text(action.label ?? ''),
                );
              }),
            ),
          ),
        ),
      _ => showModalBottomSheet(
          context: context,
          id: id,
          showDragHandle: showDragHandleOnAndroid,
          isScrollControlled: isScrollControlledOnAndroid,
          isDismissible: barrierDismissible,
          shape: shapeOnAndroid,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotNullAndNotEmpty || content.isNotNullAndNotEmpty)
                ListTile(
                  title: title.isNotNullAndNotEmpty ? Text(title!) : null,
                  subtitle: content.isNotNullAndNotEmpty ? Text(content!) : null,
                ),
              if (title.isNotNullAndNotEmpty || content.isNotNullAndNotEmpty) const Divider(),
              for (final action in actions)
                ListTile(
                  leading: action.iconOnAndroid == null ? null : Icon(action.iconOnAndroid),
                  title: Text(
                    action.label ?? '',
                    style: action.isDestructiveAction
                        ? androidIsDescructiveStyle
                        : action.isDefaultAction
                            ? androidIsDefaultStyle
                            : androidTextTheme,
                  ),
                  onTap: () {
                    action.onPressed?.call();
                    hidePopup<AdaptiveAction>(id: id, result: action);
                  },
                ),
              const SizedBox(height: 15),
              SizedBox(
                height: context.viewPadding.bottom,
              )
            ],
          ),
        ),
    };
  }

  @override
  Future<T?> singleSelectableSearchSheet<T extends SelectableSearchMixin>({
    BuildContext? context,
    List<T> items = const [],
    T? selected,
    Widget Function(BuildContext context, Widget child)? builder,
    ShapeBorder? shape,
    bool showDragHandle = false,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    String? title,
    String emptyResultText = 'Sonuç bulunamadı',
    String searchHintText = 'Bir şeyler arayın...',
    double initialSize = 0.5,
    int titleMaxLine = 2,
    int subtitleMaxLine = 1,
    TextOverflow titleOverflow = TextOverflow.ellipsis,
    TextOverflow subtitleOverflow = TextOverflow.ellipsis,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    bool showItemCount = true,
    int maxDisplayLimit = 500,
    EdgeInsetsGeometry searchFieldPadding = const EdgeInsets.all(8),
  }) {
    final id = UniqueKey().toString();
    return showModalBottomSheet(
      context: context,
      id: id,
      isScrollControlled: true,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        final child = SelectableSearchSheetView<T>.single(
          showSelectAllButton: false,
          searchFieldPadding: searchFieldPadding,
          maxDisplayLimit: maxDisplayLimit,
          popupManager: this,
          popupKey: id,
          title: title,
          emptyResultText: emptyResultText,
          items: items,
          selected: selected,
          searchHintText: searchHintText,
          initialSize: initialSize,
          titleMaxLine: titleMaxLine,
          subtitleMaxLine: subtitleMaxLine,
          titleOverflow: titleOverflow,
          subtitleOverflow: subtitleOverflow,
          controlAffinity: controlAffinity,
          showItemCount: showItemCount,
          showDragHandle: showDragHandle,
          borderRadius: borderRadius,
        );
        if (builder != null) return builder(context, child);
        return child;
      },
    );
  }

  @override
  Future<List<T>?> multiSelectableSearchSheet<T extends SelectableSearchMixin>({
    BuildContext? context,
    List<T> items = const [],
    List<T>? selectedItems,
    Widget Function(BuildContext context, Widget child)? builder,
    ShapeBorder? shape,
    bool showDragHandle = false,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    String? title,
    String emptyResultText = 'Sonuç bulunamadı',
    String searchHintText = 'Bir şeyler arayın...',
    double initialSize = 0.5,
    int titleMaxLine = 2,
    int subtitleMaxLine = 1,
    TextOverflow titleOverflow = TextOverflow.ellipsis,
    TextOverflow subtitleOverflow = TextOverflow.ellipsis,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    bool showItemCount = true,
    int maxDisplayLimit = 500,
    EdgeInsetsGeometry searchFieldPadding = const EdgeInsets.all(8),
    bool showSelectAllButton = true,
  }) {
    final id = UniqueKey().toString();
    return showModalBottomSheet(
      context: context,
      id: id,
      isScrollControlled: true,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        final child = SelectableSearchSheetView<T>.multi(
          showSelectAllButton: showSelectAllButton,
          searchFieldPadding: searchFieldPadding,
          maxDisplayLimit: maxDisplayLimit,
          popupManager: this,
          popupKey: id,
          title: title,
          emptyResultText: emptyResultText,
          items: items,
          selectedItems: selectedItems,
          searchHintText: searchHintText,
          initialSize: initialSize,
          titleMaxLine: titleMaxLine,
          subtitleMaxLine: subtitleMaxLine,
          titleOverflow: titleOverflow,
          subtitleOverflow: subtitleOverflow,
          controlAffinity: controlAffinity,
          showItemCount: showItemCount,
          showDragHandle: showDragHandle,
          borderRadius: borderRadius,
        );
        if (builder != null) return builder(context, child);
        return child;
      },
    );
  }

  /// Hides popup with given [id]
  ///
  /// If [id] is not provided hides latest one
  @override
  void hidePopup<T>({String? id, T? result}) {
    assert(
      id == null || _popupRoutes.where((element) => element.id == id).isNotEmpty,
      'Tried to close loader with id: $id which does not exist',
    );

    if (id == null) {
      final removedR = _popupRoutes.removeLast() as Route;

      (removedR as ICorePopupController).completer.complete(result);

      if (removedR.isCurrent) {
        _navigator.pop();
      } else {
        _navigator.removeRoute(removedR);
      }

      return;
    }
    final routeIndex = _popupRoutes.indexWhere((element) => element.id == id);
    final removedR = _popupRoutes.removeAt(routeIndex) as Route;

    (removedR as ICorePopupController).completer.complete(result);

    if (removedR.isCurrent) {
      _navigator.pop();
    } else {
      _navigator.removeRoute(removedR);
    }
  }

  /// Hides all popups
  @override
  void hideAllPopups() {
    for (final route in _popupRoutes) {
      _navigator.removeRoute(route as Route);
    }
    _popupRoutes.clear();
  }

  void _onCompleted(ICorePopupController controller) {
    if (_popupRoutes.contains(controller)) _popupRoutes.remove(controller);
  }

  /// Checks if popup with given [id] is open
  @override
  bool isPopupOpen({required String id}) {
    return _popupRoutes.any((element) => element.id == id);
  }
}
