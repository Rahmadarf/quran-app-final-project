import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';

/// Kartu penanda ayat: rujukan, halaman mushaf, aksi dengar/hapus, teks Arab,
/// dan terjemahan satu baris. Teks ditampilkan apa adanya dari data.
class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    super.key,
    required this.reference,
    required this.arabic,
    required this.translation,
    this.page,
    this.onTap,
    this.onListen,
    this.onRemove,
  });

  /// Mis. "QS. Ar-Rahman : 13".
  final String reference;
  final String arabic;
  final String translation;

  /// Mis. "Halaman 531".
  final String? page;
  final VoidCallback? onTap;
  final VoidCallback? onListen;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Penanda $reference',
      pressedScale: 0.99,
      child: AppSurface(
        color: AppColors.surfaceVerse,
        borderColor: AppColors.borderAt(0.3),
        radius: 12,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: AppSurface(
                          color: AppColors.surface,
                          borderColor: AppColors.border,
                          radius: 999,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          child: Text(
                            reference,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.micro.copyWith(
                              color: AppColors.accentLight,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                      if (page != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            page!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.micro.copyWith(
                              color: AppColors.textFaint,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconCircleButton(
                  icon: AppIcons.volume,
                  semanticLabel: 'Dengarkan $reference',
                  size: 32,
                  iconSize: 14,
                  iconColor: AppColors.accent,
                  onTap: onListen,
                ),
                IconCircleButton(
                  icon: AppIcons.bookmark,
                  semanticLabel: 'Hapus penanda $reference',
                  size: 32,
                  iconSize: 14,
                  iconColor: AppColors.textFaint,
                  onTap: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: Text(
                arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.arabic(
                  size: 22,
                  lineHeight: 44,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"$translation"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.custom(
                size: 13,
                lineHeight: 19.5,
                style: FontStyle.italic,
                color: AppColors.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
