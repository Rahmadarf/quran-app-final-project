import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_surface.dart';

/// Tampilan ayat tersinkronisasi dual-mode di Fullscreen Player sesuai Figma
/// `06 — Fullscreen Player (Synced)`.
class AyahLyricsView extends StatelessWidget {
  const AyahLyricsView({
    super.key,
    required this.activeArabic,
    required this.translation,
    this.previousArabic,
    this.nextArabic,
    this.ayahLabel,
  });

  final String activeArabic;
  final String translation;
  final String? previousArabic;
  final String? nextArabic;
  final String? ayahLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final dimStyle = AppTextStyles.arabic(
      size: 17,
      lineHeight: 28,
      color: palette.textMuted.withValues(alpha: 0.45),
    );

    return Semantics(
      liveRegion: true,
      label: '$activeArabic. $translation',
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (previousArabic != null) ...[
                Text(
                  previousArabic!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: dimStyle,
                ),
                const SizedBox(height: 12),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: AppSurface(
                  key: ValueKey(activeArabic),
                  color: palette.accentSoft,
                  borderColor: palette.borderAccent,
                  radius: 14,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ayahLabel != null) ...[
                        Text(
                          ayahLabel!.toUpperCase(),
                          style: AppTextStyles.micro
                              .copyWith(color: palette.accentLight),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        activeArabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppTextStyles.arabic(
                          size: 24,
                          lineHeight: 46,
                          weight: FontWeight.w400,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translation,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: palette.textMuted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (nextArabic != null) ...[
                const SizedBox(height: 12),
                Text(
                  nextArabic!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: dimStyle,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
