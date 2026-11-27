import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/badge_chip.dart';
import '../../../shared/widgets/pressable.dart';

/// Kartu tafsir/tadabbur editorial hairline dual-mode sesuai Figma `04 — Jelajah`.
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

  final String tag;
  final String meta;
  final String title;
  final String subtitle;
  final String description;
  final AppIcons leftActionIcon;
  final String leftActionLabel;
  final String rightActionLabel;
  final AppIcons? infoIcon;
  final String? infoLabel;
  final String? arabic;
  final String? arabicTranslation;
  final VoidCallback? onLeftAction;
  final VoidCallback? onRightAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      pressedScale: 0.99,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    meta.toUpperCase(),
                    style: AppTextStyles.micro
                        .copyWith(color: palette.accentLight),
                  ),
                  const Spacer(),
                  if (infoLabel != null) ...[
                    if (infoIcon != null) ...[
                      AppIcon(infoIcon!, size: 12, color: palette.textMuted),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      infoLabel!,
                      style: AppTextStyles.caption
                          .copyWith(color: palette.textMuted),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTextStyles.cardHeading
                    .copyWith(color: palette.textPrimary),
              ),
              if (arabic != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    arabic!,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.arabic(
                      size: 20,
                      lineHeight: 38,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: palette.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
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
                          size: 14,
                          color: palette.accentLight,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          leftActionLabel,
                          style: AppTextStyles.labelStrong
                              .copyWith(color: palette.accentLight),
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
                        Text(
                          rightActionLabel,
                          style: AppTextStyles.label
                              .copyWith(color: palette.textMuted),
                        ),
                        const SizedBox(width: 4),
                        AppIcon(
                          AppIcons.chevronRight,
                          size: 10,
                          color: palette.textMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu ayat pilihan dual-mode.
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

  final String reference;
  final String arabic;
  final String translation;
  final String caption;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return AppSurface(
      color: palette.surface,
      borderColor: palette.border,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIcon(AppIcons.quote, size: 18, color: palette.accent),
              BadgeChip.pill(reference),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Text(
              arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.arabic(
                size: 22,
                lineHeight: 42,
                color: palette.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '“$translation”',
            style: AppTextStyles.body.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption
                          .copyWith(color: palette.textSubtle),
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
                          style: AppTextStyles.labelStrong
                              .copyWith(color: palette.accentLight),
                        ),
                        const SizedBox(width: 4),
                        AppIcon(
                          AppIcons.chevronRight,
                          size: 9,
                          color: palette.accentLight,
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
