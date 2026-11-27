import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_surface.dart';
import 'pressable.dart';

enum AppButtonStyle {
  primary,
  tonal,
}

/// Tombol dual-mode sesuai Figma `Obsidian / Button`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.style = AppButtonStyle.tonal,
    this.height = 44,
  });

  final String label;
  final VoidCallback? onTap;
  final AppButtonStyle style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final primary = style == AppButtonStyle.primary;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AppSurface(
        color: primary ? palette.accent : palette.surfaceElevated,
        borderColor: primary ? null : palette.border,
        radius: 999,
        height: height,
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.custom(
              size: 14,
              lineHeight: 20,
              weight: FontWeight.w600,
              color: primary ? palette.onAccent : palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
