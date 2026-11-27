import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pressable.dart';

/// Kartu profil qari ringkas di dasar Fullscreen Player.
class QariFooterCard extends StatelessWidget {
  const QariFooterCard({
    super.key,
    required this.image,
    required this.name,
    required this.subtitle,
    this.label = 'Qari Utama',
    this.imageAlignment = Alignment.center,
    this.onTap,
  });

  final ImageProvider image;
  final String name;
  final String subtitle;
  final String label;
  final Alignment imageAlignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: '$label: $name. $subtitle',
      pressedScale: 0.99,
      child: AppSurface(
        color: palette.surfaceElevated.withValues(alpha: 0.9),
        borderColor: palette.border,
        blur: 12,
        radius: 16,
        padding: const EdgeInsets.all(9),
        shadows: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.border),
              ),
              child: ClipOval(
                child: Image(
                  image: ResizeImage.resizeIfNeeded(132, null, image),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  alignment: imageAlignment,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.micro.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.custom(
                      size: 12,
                      lineHeight: 16,
                      weight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.micro
                        .copyWith(color: palette.accentLight),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: AppIcon(
                AppIcons.chevronRight,
                size: 12,
                color: palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
