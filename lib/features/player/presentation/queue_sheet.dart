import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../core/utils/duration_format.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/player_controller.dart';
import '../domain/media_item.dart';

/// Membuka lembar bawah Antrean pemutar (docs/05 §5).
Future<void> showQueueSheet(BuildContext context, PlayerController player) {
  return showAppBottomSheet<void>(
    context,
    title: 'Antrean Putar',
    subtitle: player.state.queueSource ?? '${player.state.queue.length} item',
    footerHint: 'Ketuk item untuk langsung memutar.',
    builder: (context, close) => AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        final palette = AppThemeScope.paletteOf(context);
        final queue = player.state.queue;
        final activeIdx = player.state.currentIndex;

        if (queue.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  'Antrean masih kosong.',
                  style: AppTextStyles.body.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Putar Surat Ar-Rahman',
                  style: AppButtonStyle.primary,
                  onTap: () {
                    player.playSurah(55);
                    close();
                  },
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < queue.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _QueueRow(
                item: queue[i],
                active: i == activeIdx,
                onTap: () {
                  player.jumpToQueueIndex(i);
                  close();
                },
                onMoveUp: i > 0 ? () => player.reorderQueue(i, i - 1) : null,
                onMoveDown: i < queue.length - 1
                    ? () => player.reorderQueue(i, i + 1)
                    : null,
                onRemove: () => player.removeFromQueue(i),
              ),
            ],
          ],
        );
      },
    ),
  );
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.item,
    required this.active,
    required this.onTap,
    this.onMoveUp,
    this.onMoveDown,
    required this.onRemove,
  });

  final MediaItem item;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Semantics(
      selected: active,
      child: Pressable(
        onTap: onTap,
        semanticLabel: '${item.title}, ${item.subtitle}',
        child: AppSurface(
          color: active ? palette.surfaceActive : palette.surfaceElevated,
          borderColor: active ? palette.accent : palette.border,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.custom(
                        size: 13,
                        lineHeight: 18,
                        weight: FontWeight.w600,
                        color:
                            active ? palette.accentLight : palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.subtitle} · ${formatDuration(item.duration)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.custom(
                        size: 11,
                        lineHeight: 15,
                        color: palette.textMuted,
                        tabular: true,
                      ),
                    ),
                  ],
                ),
              ),
              if (onMoveUp != null)
                IconCircleButton(
                  icon: AppIcons.arrowBack,
                  semanticLabel: 'Naikkan urutan',
                  size: 32,
                  iconSize: 12,
                  iconColor: palette.textMuted,
                  onTap: onMoveUp,
                ),
              if (onMoveDown != null)
                IconCircleButton(
                  icon: AppIcons.chevronDown,
                  semanticLabel: 'Turunkan urutan',
                  size: 32,
                  iconSize: 12,
                  iconColor: palette.textMuted,
                  onTap: onMoveDown,
                ),
              IconCircleButton(
                icon: AppIcons.moreVert,
                semanticLabel: 'Hapus dari antrean',
                size: 32,
                iconSize: 14,
                iconColor: palette.textMuted,
                onTap: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
