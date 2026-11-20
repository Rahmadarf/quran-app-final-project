import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';

/// Baris riwayat tilawah: nomor surat, judul, qari dan waktu, tombol putar ulang.
class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.surahNumber,
    required this.title,
    required this.qariName,
    required this.when,
    this.onTap,
    this.onPlay,
  });

  final int surahNumber;
  final String title;
  final String qariName;

  /// Mis. "Kemarin, 21:15" atau "Hari Jumat".
  final String when;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title, $qariName, $when',
      pressedScale: 0.99,
      child: AppSurface(
        color: AppColors.surfaceVerse,
        borderColor: AppColors.borderAt(0.3),
        radius: 12,
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            AppSurface(
              shape: BoxShape.circle,
              color: AppColors.surface,
              borderColor: AppColors.border,
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  '$surahNumber',
                  style: AppTextStyles.custom(
                    size: 13,
                    lineHeight: 16,
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.rowTitle
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          qariName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.micro
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: SizedBox(
                          width: 3,
                          height: 3,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        when,
                        style: AppTextStyles.micro
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconCircleButton(
              icon: AppIcons.playOutline,
              semanticLabel: 'Putar ulang $title',
              style: IconCircleStyle.tonal,
              size: 36,
              iconSize: 13,
              iconColor: AppColors.accentLight,
              onTap: onPlay,
            ),
          ],
        ),
      ),
    );
  }
}
