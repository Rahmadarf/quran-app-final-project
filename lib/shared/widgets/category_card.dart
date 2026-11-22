import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Kartu kategori layar Jelajah: kotak ikon, judul, keterangan, ajakan aksi,
/// dan ikon besar samar sebagai hiasan di sudut kanan atas.
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
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle. $cta',
      child: AppSurface(
        color: AppColors.surfaceCard,
        borderColor: AppColors.borderAt(0.5),
        radius: 12,
        shadows: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        child: Stack(
          children: [
            Positioned(
              top: -4,
              right: -6,
              child: AppIcon(
                icon,
                size: 76,
                color: AppColors.surfaceStrong.withValues(alpha: 0.18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSurface(
                    color: AppColors.surfaceStrong,
                    radius: 8,
                    width: 36,
                    height: 36,
                    child: Center(
                      child: AppIcon(
                        icon,
                        size: 17,
                        color: AppColors.accentLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: AppTextStyles.cardHeading),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cta,
                        style: AppTextStyles.micro
                            .copyWith(color: AppColors.accentLight),
                      ),
                      const SizedBox(width: 4),
                      const AppIcon(
                        AppIcons.arrowForward,
                        size: 9,
                        color: AppColors.accentLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
