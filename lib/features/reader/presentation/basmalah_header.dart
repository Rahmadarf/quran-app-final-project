import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_surface.dart';

/// Kartu Basmalah di atas daftar ayat.
///
/// Surat 2 dan 9 tidak memuat Basmalah di dalam ayat, jadi UI menampilkannya
/// terpisah di sini. Teks Arab dan terjemahan diisi dari data, tidak diketik
/// ulang di widget (docs/06 §1).
class BasmalahHeader extends StatelessWidget {
  const BasmalahHeader({
    super.key,
    required this.arabic,
    required this.translation,
  });

  final String arabic;
  final String translation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Basmalah. $translation',
      child: ExcludeSemantics(
        child: AppSurface(
          color: AppColors.surfaceVerse,
          borderColor: AppColors.borderAt(0.4),
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.arabic(
                    size: 24,
                    lineHeight: 48,
                    color: AppColors.accentLight,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  translation,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.textSubtle,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
