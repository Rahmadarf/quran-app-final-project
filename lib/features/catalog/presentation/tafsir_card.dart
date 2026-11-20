import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/badge_chip.dart';
import '../../../shared/widgets/pressable.dart';

/// Kartu tafsir/tadabbur di layar Jelajah.
///
/// Struktur: baris atas (label + meta kiri, info kanan), judul, subjudul,
/// blok Arab opsional, ringkasan, garis, lalu dua aksi di dasar.
class TafsirCard extends StatelessWidget {
  const TafsirCard({
    super.key,
    required this.tag,
    required this.meta,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.leftActionLabel,
    required this.leftActionIcon,
    required this.rightActionLabel,
    this.infoIcon,
    this.infoLabel,
    this.arabic,
    this.arabicTranslation,
    this.onLeftAction,
    this.onRightAction,
    this.onTap,
  });

  /// Mis. "Surah ke-1", "Ayat Agung".
  final String tag;

  /// Mis. "Makkiyyah • 7 Ayat".
  final String meta;
  final String title;
  final String subtitle;
  final String description;
  final AppIcons leftActionIcon;
  final String leftActionLabel;
  final String rightActionLabel;

  /// Info kecil di kanan atas, mis. ikon timer + "14 mnt audio".
  final AppIcons? infoIcon;
  final String? infoLabel;

  /// Kutipan Arab dalam kotak gelap (opsional) dan terjemahannya.
  final String? arabic;
  final String? arabicTranslation;
  final VoidCallback? onLeftAction;
  final VoidCallback? onRightAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      pressedScale: 0.99,
      child: AppSurface(
        color: AppColors.surfaceCard,
        borderColor: AppColors.borderAt(0.5),
        radius: 12,
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BadgeChip.tag(tag),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.micro
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                if (infoLabel != null) ...[
                  if (infoIcon != null) ...[
                    AppIcon(infoIcon!, size: 11, color: AppColors.skyLabel),
                    const SizedBox(width: 4),
                  ],
                  Text(infoLabel!, style: AppTextStyles.micro),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.cardHeading),
            Text(
              subtitle,
              style: AppTextStyles.label.copyWith(color: AppColors.accentLight),
            ),
            if (arabic != null) ...[
              const SizedBox(height: 12),
              AppSurface(
                color: AppColors.backgroundAt(0.6),
                radius: 8,
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(
                      arabic!,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.arabic(
                        size: 22,
                        lineHeight: 40,
                        color: AppColors.textTitle,
                      ),
                    ),
                    if (arabicTranslation != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '"$arabicTranslation"',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.custom(
                          size: 10,
                          lineHeight: 15,
                          weight: FontWeight.w500,
                          style: FontStyle.italic,
                          color: AppColors.skyLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyRelaxed,
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderAt(0.3)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Pressable(
                      onTap: onLeftAction,
                      semanticLabel: leftActionLabel,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            leftActionIcon,
                            size: 15,
                            color: AppColors.accentLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            leftActionLabel,
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.accentLight),
                          ),
                        ],
                      ),
                    ),
                    Pressable(
                      onTap: onRightAction,
                      semanticLabel: rightActionLabel,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(rightActionLabel, style: AppTextStyles.label),
                          const SizedBox(width: 4),
                          const AppIcon(
                            AppIcons.arrowForward,
                            size: 11,
                            color: AppColors.skyLabel,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu ayat pilihan: ikon kutip, rujukan, ayat Arab, terjemahan, aksi putar.
class AyahQuoteCard extends StatelessWidget {
  const AyahQuoteCard({
    super.key,
    required this.reference,
    required this.arabic,
    required this.translation,
    required this.caption,
    required this.actionLabel,
    this.onAction,
  });

  /// Mis. "QS. Ar-Rahman: 13".
  final String reference;
  final String arabic;
  final String translation;
  final String caption;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      color: AppColors.surfaceCard,
      borderColor: AppColors.borderAt(0.5),
      radius: 12,
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppIcon(AppIcons.quote, size: 20, color: AppColors.accent),
              BadgeChip.pill(
                reference,
                textStyle: AppTextStyles.micro.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Text(
              arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.arabic(
                size: 24,
                lineHeight: 44,
                color: AppColors.textTitle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$translation"',
            style: AppTextStyles.custom(
              size: 13,
              lineHeight: 20,
              style: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderAt(0.3)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.micro.copyWith(
                        color: AppColors.textFaint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Pressable(
                    onTap: onAction,
                    semanticLabel: actionLabel,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel,
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.accentLight),
                        ),
                        const SizedBox(width: 4),
                        const AppIcon(
                          AppIcons.chevronRight,
                          size: 8,
                          color: AppColors.accentLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
