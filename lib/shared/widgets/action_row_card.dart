import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Baris aksi besar dual-mode (mis. "Buat Playlist Baru").
class ActionRowCard extends StatelessWidget {
  const ActionRowCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final AppIcons icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      pressedScale: 0.99,
      child: AppSurface(
        color: palette.surface,
        borderColor: palette.border,
        radius: 12,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AppSurface(
              color: palette.surfaceElevated,
              radius: 10,
              width: 44,
              height: 44,
              child: Center(
                child: AppIcon(icon, size: 18, color: palette.accentLight),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.rowTitle
                        .copyWith(color: palette.textPrimary),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption
                        .copyWith(color: palette.textMuted),
                  ),
                ],
              ),
            ),
            AppIcon(
              AppIcons.chevronRight,
              size: 11,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
