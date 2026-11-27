import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Kartu kategori layar Jelajah dual-mode sesuai Figma `Obsidian / CategoryTile`.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    this.onTap,
  });

  final AppIcons icon;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle. $cta',
      child: AppSurface(
        color: palette.surface,
        borderColor: palette.border,
        radius: 12,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSurface(
              color: palette.surfaceElevated,
              radius: 8,
              width: 36,
              height: 36,
              child: Center(
                child: AppIcon(
                  icon,
                  size: 18,
                  color: palette.accentLight,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardHeading
                  .copyWith(color: palette.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
