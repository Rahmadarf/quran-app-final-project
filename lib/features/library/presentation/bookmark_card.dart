import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';

/// Kartu penanda ayat dual-mode sesuai Figma `Obsidian / BookmarkCard`.
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

  final String reference;
  final String arabic;
  final String translation;
  final String? page;
  final VoidCallback? onTap;
  final VoidCallback? onListen;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: 'Penanda $reference',
      pressedScale: 0.99,
      child: AppSurface(
        color: palette.surface,
        borderColor: palette.border,
        radius: 12,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          reference.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.micro.copyWith(
                            color: palette.accentLight,
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
                            style: AppTextStyles.caption.copyWith(
                              color: palette.textMuted,
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
                  iconColor: palette.accentLight,
                  onTap: onListen,
                ),
                IconCircleButton(
                  icon: AppIcons.bookmark,
                  semanticLabel: 'Hapus penanda $reference',
                  size: 32,
                  iconSize: 14,
                  iconColor: palette.textMuted,
                  onTap: onRemove,
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
                  size: 20,
                  lineHeight: 38,
                  color: palette.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              translation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
