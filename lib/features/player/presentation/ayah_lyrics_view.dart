import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';

/// Tampilan ayat ala lirik di Fullscreen Player: ayat sebelumnya redup,
/// ayat aktif besar dan bercahaya dengan terjemahan, lalu ayat berikutnya redup.
///
/// Teks Arab ditampilkan apa adanya dari data; widget ini tidak mengubahnya.
class AyahLyricsView extends StatelessWidget {
  const AyahLyricsView({
    super.key,
    required this.activeArabic,
    required this.translation,
    this.previousArabic,
    this.nextArabic,
  });

  final String activeArabic;
  final String translation;
  final String? previousArabic;
  final String? nextArabic;

  static final Color _dim = const Color(0xFFC0C8CA).withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    final dimStyle = AppTextStyles.arabic(
      size: 18,
      lineHeight: 27,
      color: _dim,
      letterSpacing: 0.45,
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
              if (previousArabic != null)
                Text(
                  previousArabic!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: dimStyle,
                ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(activeArabic),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        activeArabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: AppTextStyles.arabic(
                          size: 32,
                          lineHeight: 52,
                          weight: FontWeight.w700,
                          color: AppColors.accentLight,
                          letterSpacing: 0.8,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: AppColors.accentAt(0.7),
                              blurRadius: 18,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Opacity(
                        opacity: 0.95,
                        child: Text(
                          '“$translation”',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.custom(
                            size: 14,
                            lineHeight: 20,
                            weight: FontWeight.w500,
                            style: FontStyle.italic,
                            color: AppColors.accentLight,
                          ).copyWith(
                            shadows: [
                              Shadow(
                                color: AppColors.accentAt(0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (nextArabic != null)
                Text(
                  nextArabic!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: dimStyle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
