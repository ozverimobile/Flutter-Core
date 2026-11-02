import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/utils/permission_manager/multiple_permission_sheet.dart';
import 'package:flutter_core/src/utils/permission_manager/single_permission_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ICorePermissionManager {
  Future<CorePermissionStatus> getPermissionStatus({required CorePermission permission});
  Future<CorePermissionStatus> requestSystemPermission({required CorePermission permission});
  Future<CorePermissionStatus> requestPermission({required CorePermission permission, BuildContext? context, String? title, String? message, Widget? icon, bool showAskLaterOption = false, bool requestWhenPostponed = false});
  Future<Map<CorePermission, CorePermissionStatus>> requestMultiplePermissions({required List<CorePermission> permissions, BuildContext? context, String? title, String? message, Widget? icon, Map<CorePermission, String>? permissionLabels, Set<CorePermission> forcedPermissions = const {}, bool showCloseButton = true, String? requestButtonLabel, String? continueButtonLabel, String? settingsButtonLabel, String? retryButtonLabel, String? forcedLabel, String? titleHighlight, String? eyebrow, Widget? eyebrowLeading, Color? accentColor, Color? buttonColor, Map<CorePermission, String>? permissionDescriptions, CoreMultiplePermissionTexts texts});
  Future<Map<CorePermission, CorePermissionStatus>?> requestMultiplePermissionsCancellable({required List<CorePermission> permissions, BuildContext? context, String? title, String? message, Widget? icon, Map<CorePermission, String>? permissionLabels, Set<CorePermission> forcedPermissions = const {}, bool showCloseButton = true, String? requestButtonLabel, String? continueButtonLabel, String? settingsButtonLabel, String? retryButtonLabel, String? forcedLabel, String? titleHighlight, String? eyebrow, Widget? eyebrowLeading, Color? accentColor, Color? buttonColor, Map<CorePermission, String>? permissionDescriptions, CoreMultiplePermissionTexts texts});
}

class CorePermissionManager implements ICorePermissionManager {
  CorePermissionManager({required GlobalKey<NavigatorState> navigatorKey})
      : _navigatorKey = navigatorKey,
        _popupManager = PopupManager(navigatorKey: navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;
  final PopupManager _popupManager;

  BuildContext get _navigatorContext {
    final state = _navigatorKey.currentState;
    assert(state != null, 'Navigator with provided key was not found in the widget tree');
    return state!.context;
  }

  @override
  Future<CorePermissionStatus> getPermissionStatus({required CorePermission permission}) async {
    try {
      final status = await (await permission.permission()).status;

      final corePermissionStatus = CorePermissionStatus.fromPermissionStatus(status);
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(permission.sharedPrefKey)) {
        if (!status.isDenied) {
          await prefs.remove(permission.sharedPrefKey);
          return corePermissionStatus;
        } else {
          final postponeMilliSeconds = prefs.getInt(permission.sharedPrefKey);
          if (postponeMilliSeconds.isNotNull && postponeMilliSeconds! > DateTime.now().millisecondsSinceEpoch) {
            return CorePermissionStatus.postponed;
          } else {
            await prefs.remove(permission.sharedPrefKey);
            return corePermissionStatus;
          }
        }
      } else {
        return corePermissionStatus;
      }
    } catch (e) {
      throw Exception('An exception occurred while getting status for permission $permission. Error was: $e');
    }
  }

  /// Izni yalnizca isletim sisteminin kendi penceresiyle ister; core'un
  /// aciklama sheet'i / diyalogu GOSTERILMEZ.
  ///
  /// Izin akisini (aciklama ekrani, ayarlara yonlendirme) kendisi kuran
  /// cagiranlar icindir. Izin zaten verilmisse pencere acilmaz; kalici
  /// reddedilmisse isletim sistemi pencere gostermez ve
  /// [CorePermissionStatus.permanentlyDenied] doner.
  @override
  Future<CorePermissionStatus> requestSystemPermission({required CorePermission permission}) async {
    try {
      final status = await (await permission.permission()).request();
      return CorePermissionStatus.fromPermissionStatus(status);
    } catch (e) {
      throw Exception('An exception occurred while requesting permission $permission. Error was: $e');
    }
  }

  @override
  Future<CorePermissionStatus> requestPermission({
    required CorePermission permission,
    BuildContext? context,
    String? title,
    String? message,
    Widget? icon,

    /// If true, the permission dialog will show the "Ask Later" option.
    ///
    /// If the user selects this option, the permission dialog won't be shown for 7 days even if the permission is requested again.
    bool showAskLaterOption = false,

    /// If true, the permission dialog will be shown when the permission is rejected.
    ///
    /// User will be prompted to grant the permission from the settings.
    bool requestWhenPermanentlyDenied = true,

    /// If true, the permission dialog will be shown even when the permission is postponed.
    bool requestWhenPostponed = false,
  }) async {
    final status = await getPermissionStatus(permission: permission);
    if (status == CorePermissionStatus.granted) return CorePermissionStatus.granted;
    if (status == CorePermissionStatus.postponed && !requestWhenPostponed) return CorePermissionStatus.postponed;
    if (!requestWhenPermanentlyDenied && status == CorePermissionStatus.permanentlyDenied) return CorePermissionStatus.permanentlyDenied;

    if (context.isNotNull && !context!.mounted) throw Exception('Context is not mounted');

    final id = UniqueKey().toString();
    Widget permissionWidget(BuildContext ctx) => SinglePermissionSheet(
      popupManager: _popupManager,
      permission: permission,
      id: id,
      isPermanentDenied: status == CorePermissionStatus.permanentlyDenied,
      showAskLaterOption: showAskLaterOption,
      title: title,
      message: message,
      icon: icon,
    );

    final effectiveContext = context ?? _navigatorContext;
    final isTablet = MediaQuery.sizeOf(effectiveContext).shortestSide >= 600;

    final CorePermissionStatus? result;
    if (isTablet) {
      result = await _popupManager.showDialog<CorePermissionStatus>(
        context: context,
        id: id,
        barrierDismissible: false,
        builder: permissionWidget,
      );
    } else {
      result = await _popupManager.showModalBottomSheet<CorePermissionStatus>(
        context: context,
        id: id,
        // Full screen page: no rounded corners from the bottom sheet theme.
        shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: false,
        isDismissible: false,
        builder: permissionWidget,
      );
    }
    return result!;
  }

  /// Shows a full screen page (dialog on tablets) listing [permissions] and requests them sequentially.
  ///
  /// If every permission is already granted, the sheet is not shown and the statuses are returned directly.
  ///
  /// Initially the primary button is shown as "İzin Ver". When tapped, permissions are
  /// requested one by one and each row is updated with the result. If any permission is
  /// denied, a "Tekrar Dene" (requestable again) or "Ayarlara Git" (permanently denied)
  /// button is shown. Statuses are refreshed when the user returns from the app settings.
  /// Once every permission is granted (after the requests or on return from the settings),
  /// the sheet closes itself as if the continue button was pressed.
  ///
  /// Returns the latest status of every requested permission. Closing the sheet with the close
  /// button also returns the statuses; use [requestMultiplePermissionsCancellable] to tell it apart.
  @override
  Future<Map<CorePermission, CorePermissionStatus>> requestMultiplePermissions({
    required List<CorePermission> permissions,
    BuildContext? context,
    String? title,
    String? message,
    Widget? icon,
    Map<CorePermission, String>? permissionLabels,
    Set<CorePermission> forcedPermissions = const {},
    bool showCloseButton = true,
    String? requestButtonLabel,
    String? continueButtonLabel,
    String? settingsButtonLabel,
    String? retryButtonLabel,
    String? forcedLabel,
    String? titleHighlight,
    String? eyebrow,
    Widget? eyebrowLeading,
    Color? accentColor,
    Color? buttonColor,
    Map<CorePermission, String>? permissionDescriptions,
    CoreMultiplePermissionTexts texts = const CoreMultiplePermissionTexts(),
  }) async {
    final result = await requestMultiplePermissionsCancellable(
      permissions: permissions,
      context: context,
      title: title,
      message: message,
      icon: icon,
      permissionLabels: permissionLabels,
      forcedPermissions: forcedPermissions,
      showCloseButton: showCloseButton,
      requestButtonLabel: requestButtonLabel,
      continueButtonLabel: continueButtonLabel,
      settingsButtonLabel: settingsButtonLabel,
      retryButtonLabel: retryButtonLabel,
      forcedLabel: forcedLabel,
      titleHighlight: titleHighlight,
      eyebrow: eyebrow,
      eyebrowLeading: eyebrowLeading,
      accentColor: accentColor,
      buttonColor: buttonColor,
      permissionDescriptions: permissionDescriptions,
      texts: texts,
    );
    return result ?? {for (final p in permissions.toSet()) p: await getPermissionStatus(permission: p)};
  }

  /// Same sheet as [requestMultiplePermissions].
  ///
  /// Returns the latest status of every requested permission, or `null` if the user closed the
  /// sheet with the close button (see [showCloseButton]). Use this when closing should mean
  /// "cancel" (e.g. do not open the screen that needed the permissions). [requestMultiplePermissions]
  /// treats closing as finishing and returns the statuses instead.
  @override
  Future<Map<CorePermission, CorePermissionStatus>?> requestMultiplePermissionsCancellable({
    required List<CorePermission> permissions,
    BuildContext? context,
    /// First line of the title. Without `title` and `titleHighlight` the title is "Başlamadan önce / birkaç izin."
    String? title,

    /// Second line of the title, in `accentColor`.
    String? titleHighlight,

    /// Paragraph under the title.
    String? message,

    /// Small caption above the title, e.g. the name of the feature asking for the permissions.
    ///
    /// Shown as is: uppercase it before passing if the design wants it uppercase.
    String? eyebrow,

    /// 22 px square widget (clipped with rounded corners) before `eyebrow`, e.g. the feature's logo.
    ///
    /// Without `eyebrow` and `eyebrowLeading` the caption row is not shown at all.
    Widget? eyebrowLeading,

    /// Shown in place of `eyebrowLeading` when it is not given. The sheet no longer has a large header icon.
    Widget? icon,

    /// Color of the title highlight, caption, permission icons and secondary button. Defaults to `colorScheme.primary`.
    ///
    /// The primary button uses `buttonColor`.
    Color? accentColor,

    /// Background of the primary button. Defaults to `colorScheme.primary`; its text color is picked by contrast.
    Color? buttonColor,

    /// Custom row titles. A short permission name ("Kamera") is used for missing entries.
    Map<CorePermission, String>? permissionLabels,

    /// Text under the row title, e.g. what the permission is used for. Replaced by the answer once requested.
    Map<CorePermission, String>? permissionDescriptions,

    /// Permissions that must be granted before the continue button is enabled.
    ///
    /// Other permissions are optional: the user can continue even if they are denied.
    /// Pass every permission to force all of them, leave empty to force none.
    Set<CorePermission> forcedPermissions = const {},
    bool showCloseButton = true,
    String? requestButtonLabel,
    String? continueButtonLabel,
    String? settingsButtonLabel,
    String? retryButtonLabel,

    /// Badge next to forced rows (when the list has both forced and optional permissions) and of the note under the list.
    String? forcedLabel,

    /// Texts that change with the state of the sheet: row answers, the note, the title once something is missing.
    CoreMultiplePermissionTexts texts = const CoreMultiplePermissionTexts(),
  }) async {
    assert(permissions.isNotEmpty, 'permissions must not be empty');
    assert(forcedPermissions.every(permissions.contains), 'forcedPermissions must be a subset of permissions');
    final uniquePermissions = permissions.toSet().toList();

    final statuses = {for (final p in uniquePermissions) p: await getPermissionStatus(permission: p)};
    if (statuses.values.every((s) => s.isGranted)) return statuses;

    if (context.isNotNull && !context!.mounted) throw Exception('Context is not mounted');

    final id = UniqueKey().toString();
    Widget sheet(BuildContext ctx) => MultiplePermissionSheet(
      popupManager: _popupManager,
      id: id,
      permissions: uniquePermissions,
      showCloseButton: showCloseButton,
      forcedPermissions: forcedPermissions,
      texts: texts,
      title: title,
      titleHighlight: titleHighlight,
      message: message,
      eyebrow: eyebrow,
      eyebrowLeading: eyebrowLeading,
      icon: icon,
      accentColor: accentColor,
      buttonColor: buttonColor,
      permissionLabels: permissionLabels,
      permissionDescriptions: permissionDescriptions,
      requestButtonLabel: requestButtonLabel,
      continueButtonLabel: continueButtonLabel,
      settingsButtonLabel: settingsButtonLabel,
      retryButtonLabel: retryButtonLabel,
      forcedLabel: forcedLabel,
    );

    final effectiveContext = context ?? _navigatorContext;
    final isTablet = MediaQuery.sizeOf(effectiveContext).shortestSide >= 600;

    final Map<CorePermission, CorePermissionStatus>? result;
    if (isTablet) {
      result = await _popupManager.showDialog<Map<CorePermission, CorePermissionStatus>>(
        context: context,
        id: id,
        barrierDismissible: false,
        builder: sheet,
      );
    } else {
      result = await _popupManager.showModalBottomSheet<Map<CorePermission, CorePermissionStatus>>(
        context: context,
        id: id,
        // Full screen page: no rounded corners from the bottom sheet theme.
        shape: const RoundedRectangleBorder(),
        isScrollControlled: true,
        enableDrag: false,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: sheet,
      );
    }
    return result;
  }
}
