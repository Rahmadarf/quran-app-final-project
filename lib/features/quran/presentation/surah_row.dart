import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../domain/surah.dart';

/// Baris satu surat pada daftar 114 surat (docs/06 §2.1, 07 §0.4).
class SurahRow extends StatelessWidget {
  const SurahRow({
    super.key,
    required this.surah,
    required this.onTap,
    required this.onPlay,
    this.isPlaying = false,
  });

  final Surah surah;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel:
          'Surat ${surah.number} ${surah.latinName}, ${surah.meaning}, ${surah.ayahCount} ayat, ${surah.revelation.label}',
      child: AppSurface(
        color: isPlaying ? AppColors.surfaceActive : AppColors.surfaceCard,
        borderColor: isPlaying ? AppColors.accent : AppColors.borderAt(0.35),
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AppSurface(
              color: AppColors.numberBadge,
              radius: 10,
              width: 38,
              height: 38,
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: AppTextStyles.custom(
                    size: 13,
                    lineHeight: 18,
                    weight: FontWeight.w700,
                    color: AppColors.accentLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.latinName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.meaning} · ${surah.ayahCount} ayat · ${surah.revelation.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              surah.arabicName,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.arabic(
                size: 18,
                lineHeight: 28,
                color: AppColors.accentLight,
              ),
            ),
            const SizedBox(width: 8),
            IconCircleButton(
              icon: isPlaying ? AppIcons.pause : AppIcons.playOutline,
              semanticLabel:
                  isPlaying ? 'Jeda ${surah.latinName}' : 'Putar ${surah.latinName}',
              style: isPlaying
                  ? IconCircleStyle.primary
                  : IconCircleStyle.ghost,
              size: 36,
              iconSize: isPlaying ? 12 : 16,
              iconColor:
                  isPlaying ? AppColors.onLight : AppColors.accentLight,
              onTap: onPlay,
            ),
          ],
        ),
      ),
    );
  }
}
