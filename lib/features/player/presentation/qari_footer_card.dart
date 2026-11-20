import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
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
    return Pressable(
      onTap: onTap,
      semanticLabel: '$label: $name. $subtitle',
      pressedScale: 0.99,
      child: AppSurface(
        color: AppColors.surfaceAt(0.8),
        borderColor: AppColors.borderAt(0.4),
        blur: 12,
        radius: 16,
        padding: const EdgeInsets.all(9),
        shadows: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightAt(0.4)),
              ),
              child: ClipOval(
                child: Image(
                  image: image,
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
                      color: AppColors.lightAt(0.7),
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
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.micro
                        .copyWith(color: AppColors.accentLight),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: AppIcon(
                AppIcons.chevronRight,
                size: 12,
                color: Color(0xFF8CA9BA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
