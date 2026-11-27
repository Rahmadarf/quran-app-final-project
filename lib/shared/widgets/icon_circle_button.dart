import 'package:flutter/widgets.dart';

import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

enum IconCircleStyle {
  ghost,
  tonal,
  outlined,
  primary,
  glass,
}

/// Tombol bulat dual-mode berisi satu ikon sesuai `Obsidian / IconButton`.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.size = 40,
    this.iconSize,
    this.style = IconCircleStyle.ghost,
    this.iconColor,
    this.glow = false,
    this.dot = false,
  });

  final AppIcons icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final double size;
  final double? iconSize;
  final IconCircleStyle style;
  final Color? iconColor;
  final bool glow;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final isPrimary = style == IconCircleStyle.primary;
    final color = iconColor ??
        (isPrimary ? palette.onAccent : palette.textPrimary);

    Widget glyph = AppIcon(icon, size: iconSize ?? size * 0.42, color: color);
    if (dot) {
      glyph = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          glyph,
          Positioned(
            bottom: -(size * 0.2),
            child: SizedBox(
              width: 4,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final surface = switch (style) {
      IconCircleStyle.ghost => AppSurface(
          shape: BoxShape.circle,
          width: size,
          height: size,
          clip: false,
          child: Center(child: glyph),
        ),
      IconCircleStyle.tonal => AppSurface(
          shape: BoxShape.circle,
          color: palette.surfaceElevated,
          width: size,
          height: size,
          child: Center(child: glyph),
        ),
      IconCircleStyle.outlined => AppSurface(
          shape: BoxShape.circle,
          color: palette.surface,
          borderColor: palette.border,
          width: size,
          height: size,
          child: Center(child: glyph),
        ),
      IconCircleStyle.primary => AppSurface(
          shape: BoxShape.circle,
          color: palette.accent,
          width: size,
          height: size,
          clip: false,
          shadows: glow
              ? [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
          child: Center(child: glyph),
        ),
      IconCircleStyle.glass => AppSurface(
          shape: BoxShape.circle,
          color: palette.surface.withValues(alpha: 0.88),
          borderColor: palette.borderStrong,
          blur: 12,
          width: size,
          height: size,
          child: Center(child: glyph),
        ),
    };

    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: surface,
    );
  }
}
