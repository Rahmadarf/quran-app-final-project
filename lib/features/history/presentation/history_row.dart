import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';

/// Baris riwayat tilawah zero-card hairline dual-mode.
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
  final String when;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: '$title, $qariName, $when',
      pressedScale: 0.99,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              AppSurface(
                color: palette.surface,
                borderColor: palette.border,
                radius: 8,
                width: 36,
                height: 36,
                child: Center(
                  child: Text(
                    surahNumber.toString().padLeft(2, '0'),
                    style: AppTextStyles.label.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w600,
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
                          .copyWith(color: palette.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$qariName · $when',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption
                          .copyWith(color: palette.textMuted),
                    ),
                  ],
                ),
              ),
              IconCircleButton(
                icon: AppIcons.play,
                semanticLabel: 'Putar ulang $title',
                style: IconCircleStyle.tonal,
                size: 34,
                iconSize: 13,
                iconColor: palette.textPrimary,
                onTap: onPlay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
