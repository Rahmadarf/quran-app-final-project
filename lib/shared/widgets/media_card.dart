import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'badge_chip.dart';
import 'pressable.dart';

/// Kartu sampul persegi dengan judul di bawahnya (rak Beranda).
///
/// Dua gaya isi sampul:
/// - surat: [arabicTitle] di kiri-bawah dan [pillLabel] opsional di kanan-bawah;
/// - kurasi: [badgeIcon] di kiri-atas dan [overlayLabel] huruf kapital di bawah.
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
    this.width = 144,
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

  static const double coverHeight = 142;

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.surface,
              borderColor: AppColors.borderAt(0.6),
              radius: 16,
              height: coverHeight + 2,
              shadows: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -1,
                ),
              ],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: image,
                    fit: BoxFit.cover,
                    alignment: imageAlignment,
                    excludeFromSemantics: true,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          curated
                              ? const Color(0xF2000D29) // 0.95
                              : const Color(0xE6000D29), // 0.9
                          curated
                              ? AppColors.surface.withValues(alpha: 0)
                              : AppColors.background.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                style: AppTextStyles.cardTitle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
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
                size: 16,
                lineHeight: 16,
                weight: FontWeight.w700,
                color: AppColors.accentLight,
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
            color: AppColors.surfaceAt(0.8),
            borderColor: AppColors.accentAt(0.4),
            blur: 12,
            width: 24,
            height: 24,
            child: Center(
              child: AppIcon(
                badgeIcon!,
                size: 12,
                color: AppColors.accentLight,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        if (overlayLabel != null)
          Text(
            overlayLabel!,
            style: AppTextStyles.micro.copyWith(
              color: overlayLabelColor,
              letterSpacing: 0.25,
            ),
          ),
      ],
    );
  }
}
