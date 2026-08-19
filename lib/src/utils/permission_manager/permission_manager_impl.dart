import 'dart:async';

import 'package:flutter_core/flutter_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ICorePermissionManager {
  Future<CorePermissionStatus> getPermissionStatus({required CorePermission permission});
  Future<CorePermissionStatus> requestPermission({required CorePermission permission, BuildContext? context, String? title, String? message, Widget? icon, bool showAskLaterOption = false, bool requestWhenPostponed = false});
}

class CorePermissionManager implements ICorePermissionManager {
  CorePermissionManager({required GlobalKey<NavigatorState> navigatorKey}) : _navigatorKey = navigatorKey, _popupManager = PopupManager(navigatorKey: navigatorKey);

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
    Widget permissionWidget(BuildContext ctx) => _PermissionWidget(
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
        isScrollControlled: true,
        enableDrag: false,
        isDismissible: false,
        builder: permissionWidget,
      );
    }
    return result!;
  }
}

@immutable
final class _PermissionWidget extends StatefulWidget {
  const _PermissionWidget({
    required this.popupManager,
    required this.permission,
    required this.id,
    required this.isPermanentDenied,
    required this.showAskLaterOption,
    this.title,
    this.message,
    this.icon,
  });

  final PopupManager popupManager;
  final CorePermission permission;
  final String id;
  final bool isPermanentDenied;
  final bool showAskLaterOption;
  final String? title;
  final String? message;
  final Widget? icon;

  @override
  State<_PermissionWidget> createState() => _PermissionWidgetState();
}

final class _PermissionWidgetState extends State<_PermissionWidget> {
  var _title = '';
  var _message = '';
  Widget _icon = const SizedBox();

  Completer<void>? _completer;

  late final AppLifecycleListener _appLifecycleListener;

  @override
  void initState() {
    _appLifecycleListener = AppLifecycleListener(onStateChange: _onStateChange);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _initWidgets();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  bool get _isTablet => MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    return _isTablet ? _buildDialogLayout(context) : _buildBottomSheetLayout(context);
  }

  Widget _buildBottomSheetLayout(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: context.height,
        width: context.width,
        color: context.colorScheme.surface,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  const SizedBox(height: kToolbarHeight),
                  SizedBox(height: context.height * 0.1),
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: context.colorScheme.primary,
                    child: _icon,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CoreText.displaySmall(
                          _title,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                          textColor: context.colorScheme.onSurface,
                        ),
                        verticalBox12,
                        CoreText.titleMedium(
                          _message,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                          textColor: context.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                  _buildPrimaryButton(context, fullWidth: true),
                  if (widget.showAskLaterOption && !widget.isPermanentDenied) ...[
                    verticalBox8,
                    _buildAskLaterButton(context, fullWidth: true),
                  ],
                  verticalBox24,
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Column(
                  children: [
                    const SizedBox(height: kToolbarHeight),
                    _buildCloseButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogLayout(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 480,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildCloseButton(context),
                ),
                verticalBox12,
                CircleAvatar(
                  radius: 52,
                  backgroundColor: context.colorScheme.primary,
                  child: _icon,
                ),
                verticalBox24,
                CoreText.headlineMedium(
                  _title,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  textColor: context.colorScheme.onSurface,
                ),
                verticalBox12,
                CoreText.bodyLarge(
                  _message,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                  textColor: context.colorScheme.onSurface,
                ),
                const SizedBox(height: 32),
                _buildPrimaryButton(context, fullWidth: true),
                if (widget.showAskLaterOption && !widget.isPermanentDenied) ...[
                  verticalBox8,
                  _buildAskLaterButton(context, fullWidth: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return CoreIconButton.filled(
      onPressed: () => widget.popupManager.hidePopup<CorePermissionStatus>(
        id: widget.id,
        result: CorePermissionStatus.neverPrompted,
      ),
      icon: Icon(Icons.close, color: context.colorScheme.onPrimary),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, {required bool fullWidth}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: CoreFilledButton(
        borderRadius: BorderRadius.circular(18),
        onPressed: () async {
          if (widget.isPermanentDenied) {
            final alertDialogId = UniqueKey().toString();
            final isUserOpenedAppSettings = await widget.popupManager.showDefaultAdaptiveAlertDialog<bool>(
              context: context,
              id: alertDialogId,
              title: const Text('İzin Gerekli'),
              content: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Ayarlardan '),
                    TextSpan(
                      text: _title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' vermeniz gerekmektedir'),
                  ],
                ),
              ),
              okButtonLabel: 'Ayarları aç',
              cancelButtonLabel: 'İptal',
              isDestructiveCancelButtonIOS: true,
              onOkButtonPressed: () => widget.popupManager.hidePopup<bool>(id: alertDialogId, result: true),
            );

            if (isUserOpenedAppSettings ?? false) {
              _completer = Completer<void>();
              await openAppSettings();
              await _completer!.future;
            } else {
              widget.popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: CorePermissionStatus.permanentlyDenied);
              return;
            }

            final status = await (await widget.permission.permission()).status;
            try {
              widget.popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: CorePermissionStatus.fromPermissionStatus(status));
            } catch (e) {
              throw Exception('An exception occurred while getting status for permission ${widget.permission}. Error was: $e');
            }
          } else {
            final permission = await widget.permission.permission();
            final result = await permission.request();
            widget.popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: CorePermissionStatus.fromPermissionStatus(result));
          }
        },
        minSize: 50,
        child: CoreText.titleMedium(
          'Devam Et',
          textColor: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAskLaterButton(BuildContext context, {required bool fullWidth}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: CoreTextButton(
        borderRadius: BorderRadius.circular(18),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(widget.permission.sharedPrefKey, _postponeMilliseconds);
          widget.popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: CorePermissionStatus.postponed);
        },
        minSize: 50,
        child: CoreText.titleMedium(
          'Sonra Hatırlat',
          textColor: context.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _initWidgets() async {
    _title = widget.title ?? await widget.permission.title();
    _message = widget.message ?? await widget.permission.message();
    if (!mounted) return;
    _icon = widget.icon ?? widget.permission.icon(context);
    scheduleMicrotask(() {
      if (mounted) setState(() {});
    });
  }

  void _onStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _completer?.complete();
  }
}

int get _postponeMilliseconds {
  // 7 days
  return DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 24 * 7;
}
