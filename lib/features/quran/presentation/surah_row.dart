import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../domain/surah.dart';

/// Baris satu surat bergaya zero-card hairline sesuai Figma `Obsidian / SurahRow`.
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
    final palette = AppThemeScope.paletteOf(context);
    final paddedNo = surah.number.toString().padLeft(2, '0');

    return Pressable(
      onTap: onTap,
      semanticLabel:
          'Surat ${surah.number} ${surah.latinName}, ${surah.meaning}, ${surah.ayahCount} ayat, ${surah.revelation.label}',
      pressedScale: 0.99,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              AppSurface(
                color: isPlaying ? palette.accentSoft : palette.surface,
                borderColor:
                    isPlaying ? palette.borderAccent : palette.border,
                radius: 8,
                width: 36,
                height: 36,
                child: Center(
                  child: Text(
                    paddedNo,
                    style: AppTextStyles.label.copyWith(
                      color: isPlaying
                          ? palette.accentLight
                          : palette.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.latinName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: isPlaying
                            ? palette.accentLight
                            : palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPlaying
                          ? 'Sedang diputar · ${surah.ayahCount} Ayat'
                          : '${surah.meaning} · ${surah.ayahCount} Ayat · ${surah.revelation.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: isPlaying
                            ? palette.accentLight
                            : palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                surah.arabicName,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.arabic(
                  size: 20,
                  lineHeight: 30,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              IconCircleButton(
                icon: isPlaying ? AppIcons.pause : AppIcons.play,
                semanticLabel: isPlaying
                    ? 'Jeda ${surah.latinName}'
                    : 'Putar ${surah.latinName}',
                style: isPlaying
                    ? IconCircleStyle.primary
                    : IconCircleStyle.tonal,
                size: 34,
                iconSize: 13,
                iconColor:
                    isPlaying ? palette.onAccent : palette.textPrimary,
                onTap: onPlay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
