import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

// Building blocks shared by the single and the multiple permission pages, so both read as one design.

/// Colors of a permission page, resolved from the theme unless given.
@immutable
final class PermissionPalette {
  const PermissionPalette._({
    required this.accent,
    required this.onAccent,
    required this.button,
    required this.onButton,
    required this.success,
    required this.info,
    required this.error,
  });

  /// [accent] defaults to `colorScheme.primary`. [button] defaults to the filled button theme, then
  /// `colorScheme.primary`: the button is given its color explicitly because on iOS `CoreFilledButton`
  /// uses `colorScheme.primary` while elsewhere it follows the filled button theme.
  factory PermissionPalette.of(BuildContext context, {Color? accent, Color? button}) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final themeButton = context.theme.filledButtonTheme.style;
    final themeBackground = themeButton?.backgroundColor?.resolve(const <WidgetState>{});

    final Color effectiveButton;
    final Color onButton;
    if (button != null) {
      effectiveButton = button;
      onButton = _contrastOn(button);
    } else if (themeBackground != null) {
      effectiveButton = themeBackground;
      onButton = themeButton?.foregroundColor?.resolve(const <WidgetState>{}) ?? _contrastOn(themeBackground);
    } else {
      effectiveButton = scheme.primary;
      onButton = scheme.onPrimary;
    }

    return PermissionPalette._(
      accent: accent ?? scheme.primary,
      onAccent: accent == null ? scheme.onPrimary : _contrastOn(accent),
      button: effectiveButton,
      onButton: onButton,
      success: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
      info: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      error: scheme.error,
    );
  }

  /// Title highlight, caption, icon tiles and text buttons.
  final Color accent;
  final Color onAccent;

  /// Primary button.
  final Color button;
  final Color onButton;

  final Color success;
  final Color info;
  final Color error;

  static Color _contrastOn(Color color) => ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black;
}

/// Full screen page on phones, dialog on tablets: close button on top, scrollable [body], [bottom] pinned below.
final class PermissionPage extends StatelessWidget {
  const PermissionPage({required this.body, required this.bottom, this.closeButton, super.key});

  final Widget? closeButton;
  final List<Widget> body;
  final List<Widget> bottom;

  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    if (isTablet(context)) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        backgroundColor: context.colorScheme.surface,
        child: SizedBox(
          width: 480,
          child: Padding(padding: const EdgeInsets.fromLTRB(32, 16, 32, 32), child: _buildContent(expand: false)),
        ),
      );
    }

    // A modal bottom sheet removes the top padding from its MediaQuery, so SafeArea would let the close
    // button slide under the status bar; the insets are read from the view instead.
    final insets = MediaQueryData.fromView(View.of(context)).padding;
    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height,
      color: context.theme.scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(24, insets.top + 16, 24, insets.bottom + 16),
      child: _buildContent(expand: true),
    );
  }

  Widget _buildContent({required bool expand}) {
    final scrollable = SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: body));
    return Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(alignment: Alignment.centerRight, child: closeButton ?? const CoreSizedBox(height: 36)),
        verticalBox12,
        if (expand) Expanded(child: scrollable) else Flexible(child: scrollable),
        verticalBox16,
        ...bottom,
      ],
    );
  }
}

final class PermissionCloseButton extends StatelessWidget {
  const PermissionCloseButton({required this.onPressed, super.key});

  /// `null` disables the button, e.g. while a system dialog is open.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        padding: EdgeInsets.zero,
        backgroundColor: context.colorScheme.onSurface.withValues(alpha: 0.06),
        disabledBackgroundColor: context.colorScheme.onSurface.withValues(alpha: 0.03),
      ),
      icon: Icon(Icons.close, size: 20, color: context.colorScheme.onSurfaceVariant),
    );
  }
}

/// Two line title, the second line in the accent color.
final class PermissionHeading extends StatelessWidget {
  const PermissionHeading({required this.line, required this.highlight, required this.accent, super.key});

  final String? line;
  final String? highlight;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // The theme's font, at a fixed size: Material's displaySmall is 36 too, but app themes often shrink it.
    final style = context.theme.textTheme.displaySmall?.copyWith(fontSize: 36, height: 1.1, letterSpacing: -0.8, fontWeight: FontWeight.bold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (line != null) CoreText(line, style: style?.copyWith(color: context.colorScheme.onSurface)),
        if (highlight != null) CoreText(highlight, style: style?.copyWith(color: accent)),
      ],
    );
  }
}

final class PermissionBadge extends StatelessWidget {
  const PermissionBadge({required this.label, required this.color, this.radius = 999, super.key});

  final String label;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(radius)),
      child: CoreText.labelMedium(label, textColor: color, fontWeight: FontWeight.w600),
    );
  }
}

/// Badge and explanation: why the permission is asked, optional or required. An empty [note] draws nothing.
final class PermissionNote extends StatelessWidget {
  const PermissionNote({required this.label, required this.note, required this.color, super.key});

  final String label;
  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (note.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PermissionBadge(label: label, color: color),
          horizontalBox12,
          Expanded(child: CoreText.bodyMedium(note, textColor: context.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

final class PermissionPrimaryButton extends StatelessWidget {
  const PermissionPrimaryButton({required this.label, required this.onPressed, required this.palette, this.icon, super.key});

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final PermissionPalette palette;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = onPressed == null ? context.colorScheme.onSurface.withValues(alpha: 0.38) : palette.onButton;
    return SizedBox(
      width: double.infinity,
      child: CoreFilledButton(
        borderRadius: BorderRadius.circular(20),
        minSize: 50,
        backgroundColor: palette.button,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: foreground), const CoreSizedBox(width: 6)],
            CoreText.titleSmall(label, textColor: foreground, fontWeight: FontWeight.bold),
          ],
        ),
      ),
    );
  }
}
