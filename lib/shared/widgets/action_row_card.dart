import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Baris aksi besar dengan kotak ikon di kiri dan panah di kanan
/// (mis. "Buat Playlist Baru").
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
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      pressedScale: 0.99,
      child: AppSurface(
        color: AppColors.surfaceDeep,
        borderColor: AppColors.borderAt(0.3),
        radius: 12,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            AppSurface(
              color: AppColors.surface,
              radius: 12,
              width: 48,
              height: 48,
              child: Center(
                child: AppIcon(icon, size: 19, color: AppColors.accentLight),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.rowTitle),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textFaint),
                  ),
                ],
              ),
            ),
            const AppIcon(
              AppIcons.chevronRight,
              size: 10,
              color: AppColors.placeholder,
            ),
          ],
        ),
      ),
    );
  }
}
