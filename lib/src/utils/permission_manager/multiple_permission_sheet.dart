import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:permission_handler/permission_handler.dart';

enum _SheetPhase { initial, requesting, completed }

enum _ItemStatus {
  idle,
  requesting,
  granted,
  denied,
  permanentlyDenied;

  static _ItemStatus fromPermissionStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted || PermissionStatus.limited || PermissionStatus.provisional => _ItemStatus.granted,
      PermissionStatus.permanentlyDenied || PermissionStatus.restricted => _ItemStatus.permanentlyDenied,
      PermissionStatus.denied => _ItemStatus.denied,
    };
  }

  CorePermissionStatus toCorePermissionStatus() {
    return switch (this) {
      _ItemStatus.granted => CorePermissionStatus.granted,
      _ItemStatus.permanentlyDenied => CorePermissionStatus.permanentlyDenied,
      _ItemStatus.idle || _ItemStatus.requesting || _ItemStatus.denied => CorePermissionStatus.neverPrompted,
    };
  }
}

@immutable
final class MultiplePermissionSheet extends StatefulWidget {
  const MultiplePermissionSheet({
    required this.popupManager,
    required this.id,
    required this.permissions,
    required this.showCloseButton,
    required this.forcedPermissions,
    this.title,
    this.message,
    this.icon,
    this.permissionLabels,
    this.requestButtonLabel,
    this.continueButtonLabel,
    this.settingsButtonLabel,
    this.retryButtonLabel,
    this.forcedLabel,
    super.key,
  });

  final PopupManager popupManager;
  final String id;
  final List<CorePermission> permissions;
  final bool showCloseButton;
  final Set<CorePermission> forcedPermissions;
  final String? title;
  final String? message;
  final Widget? icon;
  final Map<CorePermission, String>? permissionLabels;
  final String? requestButtonLabel;
  final String? continueButtonLabel;
  final String? settingsButtonLabel;
  final String? retryButtonLabel;
  final String? forcedLabel;

  @override
  State<MultiplePermissionSheet> createState() => _MultiplePermissionSheetState();
}

final class _MultiplePermissionSheetState extends State<MultiplePermissionSheet> {
  static const _requestInterval = Duration(milliseconds: 300);

  late final AppLifecycleListener _appLifecycleListener;
  late final Map<CorePermission, _ItemStatus> _statuses = {for (final p in widget.permissions) p: _ItemStatus.idle};
  final Map<CorePermission, String> _labels = {};

  _SheetPhase _phase = _SheetPhase.initial;
  var _isWaitingForSettings = false;

  bool get _isTablet => MediaQuery.sizeOf(context).shortestSide >= 600;
  bool get _isAllGranted => _statuses.values.every((s) => s == _ItemStatus.granted);
  bool get _isForcedGranted => widget.forcedPermissions.every((p) => _statuses[p] == _ItemStatus.granted);
  bool get _hasMixedForce => widget.forcedPermissions.isNotEmpty && widget.forcedPermissions.length < widget.permissions.length;
  bool get _hasPermanentlyDenied => _statuses.values.any((s) => s == _ItemStatus.permanentlyDenied);

  Map<CorePermission, CorePermissionStatus> get _result => _statuses.map((p, s) => MapEntry(p, s.toCorePermissionStatus()));

  @override
  void initState() {
    _appLifecycleListener = AppLifecycleListener(onResume: _onResume);
    unawaited(_init());
    super.initState();
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    for (final permission in widget.permissions) {
      _labels[permission] = widget.permissionLabels?[permission] ?? await permission.title();
      final status = await (await permission.permission()).status;
      if (status.isGranted || status.isLimited || status.isProvisional) _statuses[permission] = _ItemStatus.granted;
    }
    if (mounted) setState(() {});
  }

  Future<void> _requestAll() async {
    setState(() => _phase = _SheetPhase.requesting);

    for (final permission in widget.permissions) {
      if (_statuses[permission] == _ItemStatus.granted) continue;
      if (!mounted) return;
      setState(() => _statuses[permission] = _ItemStatus.requesting);

      final status = await (await permission.permission()).request();
      if (!mounted) return;
      setState(() => _statuses[permission] = _ItemStatus.fromPermissionStatus(status));
      await Future<void>.delayed(_requestInterval);
    }

    if (mounted) setState(() => _phase = _SheetPhase.completed);
  }

  Future<void> _openSettings() async {
    _isWaitingForSettings = true;
    await openAppSettings();
  }

  Future<void> _onResume() async {
    if (!_isWaitingForSettings) return;
    _isWaitingForSettings = false;
    for (final permission in widget.permissions) {
      final status = await (await permission.permission()).status;
      _statuses[permission] = _ItemStatus.fromPermissionStatus(status);
    }
    if (mounted) setState(() {});
  }

  void _close() => widget.popupManager.hidePopup<Map<CorePermission, CorePermissionStatus>>(id: widget.id, result: _result);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: _isTablet ? _buildDialogLayout(context) : _buildBottomSheetLayout(context),
    );
  }

  Widget _buildBottomSheetLayout(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildDialogLayout(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      backgroundColor: context.colorScheme.surface,
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: CoreText.headlineSmall(
                  widget.title,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  textColor: context.colorScheme.onSurface,
                ),
              ),
            if (widget.message != null) ...[
              verticalBox8,
              CoreText.bodyMedium(
                widget.message,
                textAlign: TextAlign.center,
                textColor: context.colorScheme.onSurfaceVariant,
              ),
            ],
            verticalBox24,
            _buildHeaderIcon(context),
            verticalBox24,
            Flexible(
              child: SingleChildScrollView(
                child: Center(
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final permission in widget.permissions) _buildPermissionItem(context, permission),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            verticalBox24,
            _buildSecondaryButton(context),
            _buildPrimaryButton(context),
          ],
        ),
        if (widget.showCloseButton)
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              onPressed: _phase == _SheetPhase.requesting ? null : _close,
              icon: Icon(Icons.close, color: context.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderIcon(BuildContext context) {
    final IconData iconData;
    if (_phase != _SheetPhase.completed) {
      iconData = Icons.admin_panel_settings;
    } else if (_isAllGranted) {
      iconData = Icons.verified_user;
    } else {
      iconData = Icons.gpp_maybe;
    }

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: widget.icon ??
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: Icon(iconData, key: ValueKey(iconData), size: 52, color: context.colorScheme.onPrimary),
          ),
    );
  }

  Widget _buildPermissionItem(BuildContext context, CorePermission permission) {
    final status = _statuses[permission]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 28,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: _buildStatusIcon(context, permission, status),
            ),
          ),
          horizontalBox12,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CoreText.bodyLarge(
                  _labels[permission] ?? '',
                  textColor: context.colorScheme.onSurface,
                ),
                if (_hasMixedForce && widget.forcedPermissions.contains(permission))
                  CoreText.labelSmall(
                    widget.forcedLabel ?? 'Zorunlu',
                    textColor: context.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, CorePermission permission, _ItemStatus status) {
    return switch (status) {
      _ItemStatus.idle => Icon(permission.iconData, key: const ValueKey(_ItemStatus.idle), size: 26, color: context.colorScheme.primary),
      _ItemStatus.requesting => Padding(
          key: const ValueKey(_ItemStatus.requesting),
          padding: const EdgeInsets.all(4),
          child: CircularProgressIndicator.adaptive(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(context.colorScheme.primary)),
        ),
      _ItemStatus.granted => const Icon(Icons.check_circle, key: ValueKey(_ItemStatus.granted), size: 26, color: Colors.green),
      _ItemStatus.denied || _ItemStatus.permanentlyDenied => Icon(Icons.cancel, key: const ValueKey(_ItemStatus.denied), size: 26, color: context.colorScheme.error),
    };
  }

  Widget _buildSecondaryButton(BuildContext context) {
    final isVisible = _phase == _SheetPhase.completed && !_isAllGranted;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: !isVisible
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: CoreTextButton(
                  onPressed: _hasPermanentlyDenied ? _openSettings : _requestAll,
                  child: CoreText.titleSmall(
                    _hasPermanentlyDenied ? (widget.settingsButtonLabel ?? 'Ayarlara Git') : (widget.retryButtonLabel ?? 'Tekrar Dene'),
                    textColor: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final isInitial = _phase == _SheetPhase.initial;
    final onPressed = switch (_phase) {
      _SheetPhase.initial => _requestAll,
      _SheetPhase.requesting => null,
      _SheetPhase.completed => _isForcedGranted ? _close : null,
    };

    return SizedBox(
      width: double.infinity,
      child: CoreFilledButton(
        borderRadius: BorderRadius.circular(18),
        minSize: 50,
        onPressed: onPressed,
        child: CoreText.titleMedium(
          isInitial ? (widget.requestButtonLabel ?? 'İzin Ver') : (widget.continueButtonLabel ?? 'Devam Et'),
          textColor: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
