import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'badge_chip.dart';
import 'pressable.dart';

/// Kartu sampul persegi dual-mode sesuai Figma `Obsidian / MediaCard`.
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.arabicTitle,
    this.pillLabel,
    this.badgeIcon,
    this.overlayLabel,
    this.overlayLabelColor = AppColors.accentLight,
    this.imageAlignment = Alignment.center,
    this.width = 148,
    this.onTap,
  });

  final ImageProvider image;
  final String title;
  final String subtitle;
  final String? arabicTitle;
  final String? pillLabel;
  final AppIcons? badgeIcon;
  final String? overlayLabel;
  final Color overlayLabelColor;
  final Alignment imageAlignment;
  final double width;
  final VoidCallback? onTap;

  static const double coverHeight = 148;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final curated = badgeIcon != null || overlayLabel != null;

    return Pressable(
      onTap: onTap,
      semanticLabel: '$title, $subtitle',
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSurface(
              color: palette.surface,
              borderColor: palette.border,
              radius: 12,
              height: coverHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: ResizeImage.resizeIfNeeded(
                      (width * 3).round(),
                      null,
                      image,
                    ),
                    fit: BoxFit.cover,
                    alignment: imageAlignment,
                    excludeFromSemantics: true,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xCC0A0B0D),
                          Color(0x0D0A0B0D),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: curated ? _curatedContent() : _surahContent(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle
                    .copyWith(color: palette.textPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: palette.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _surahContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (arabicTitle != null)
          Flexible(
            child: Text(
              arabicTitle!,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.arabic(
                size: 20,
                lineHeight: 28,
                weight: FontWeight.w400,
                // Tetap putih terang di atas scrim foto gelap pada kedua mode.
                color: const Color(0xFFF8F9FA),
              ),
            ),
          ),
        if (pillLabel != null) BadgeChip.pill(pillLabel!),
      ],
    );
  }

  Widget _curatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (badgeIcon != null)
          AppSurface(
            shape: BoxShape.circle,
            color: const Color(0xCC131519),
            borderColor: const Color(0x33FFFFFF),
            width: 28,
            height: 28,
            child: Center(
              child: AppIcon(
                badgeIcon!,
                size: 13,
                color: const Color(0xFF34D399),
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        if (overlayLabel != null)
          Text(
            overlayLabel!,
            style: AppTextStyles.micro.copyWith(
              color: const Color(0xFFF8F9FA),
              letterSpacing: 0.6,
            ),
          ),
      ],
    );
  }
}
