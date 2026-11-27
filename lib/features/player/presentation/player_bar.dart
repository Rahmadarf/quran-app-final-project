import 'package:flutter/widgets.dart' hide RepeatMode;

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../core/utils/duration_format.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/icon_circle_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/player_controller.dart';
import '../application/player_providers.dart';
import '../domain/player_state.dart';
import 'seek_bar.dart';

/// Player Bar lebar dual-mode untuk layar Expanded (≥ 840 dp).
class PlayerBar extends StatelessWidget {
  const PlayerBar({
    super.key,
    required this.onExpand,
    required this.onQueueTap,
    required this.onSpeedTap,
    required this.onSleepTap,
  });

  final VoidCallback onExpand;
  final VoidCallback onQueueTap;
  final VoidCallback onSpeedTap;
  final VoidCallback onSleepTap;

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final palette = AppThemeScope.paletteOf(context);
    final state = player.state;
    final current = state.current;
    final title = current?.title ?? 'Surah Ar-Rahman';
    final subtitle = current?.subtitle ?? player.selectedQariName;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: SizedBox(
        height: 84,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Pressable(
                      onTap: onExpand,
                      semanticLabel: 'Buka pemutar penuh',
                      child: AppSurface(
                        width: 48,
                        height: 48,
                        radius: 10,
                        color: palette.surfaceElevated,
                        borderColor: palette.border,
                        child: Image(
                          image: ResizeImage.resizeIfNeeded(
                            144,
                            null,
                            AssetImage(
                              current?.artwork ??
                                  'assets/images/covers/ar-rahman.png',
                            ),
                          ),
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Pressable(
                        onTap: onExpand,
                        semanticLabel: '$title, $subtitle. Buka pemutar penuh',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle
                                  .copyWith(color: palette.textPrimary),
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption
                                  .copyWith(color: palette.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconCircleButton(
                      icon: player.favorite
                          ? AppIcons.heartFilled
                          : AppIcons.heart,
                      semanticLabel:
                          player.favorite ? 'Hapus dari favorit' : 'Favoritkan',
                      size: 36,
                      iconSize: 16,
                      iconColor: player.favorite
                          ? palette.accent
                          : palette.textMuted,
                      onTap: player.toggleFavorite,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconCircleButton(
                          icon: AppIcons.shuffle,
                          semanticLabel:
                              state.shuffle ? 'Acak aktif' : 'Acak mati',
                          size: 36,
                          iconSize: 14,
                          iconColor: state.shuffle
                              ? palette.accentLight
                              : palette.textMuted,
                          dot: state.shuffle,
                          onTap: player.toggleShuffle,
                        ),
                        const SizedBox(width: 8),
                        IconCircleButton(
                          icon: AppIcons.previous,
                          semanticLabel: 'Sebelumnya',
                          size: 36,
                          iconSize: 14,
                          iconColor: palette.textPrimary,
                          onTap: player.previous,
                        ),
                        const SizedBox(width: 8),
                        IconCircleButton(
                          icon:
                              state.isPlaying ? AppIcons.pause : AppIcons.play,
                          semanticLabel: state.isPlaying ? 'Jeda' : 'Putar',
                          style: IconCircleStyle.primary,
                          size: 40,
                          iconSize: 14,
                          onTap: player.togglePlay,
                        ),
                        const SizedBox(width: 8),
                        IconCircleButton(
                          icon: AppIcons.next,
                          semanticLabel: 'Berikutnya',
                          size: 36,
                          iconSize: 14,
                          iconColor: palette.textPrimary,
                          onTap: player.next,
                        ),
                        const SizedBox(width: 8),
                        IconCircleButton(
                          icon: state.repeat == RepeatMode.one
                              ? AppIcons.repeatOne
                              : AppIcons.repeat,
                          semanticLabel: _repeatLabel(state.repeat),
                          size: 36,
                          iconSize: 15,
                          iconColor: state.repeat != RepeatMode.off
                              ? palette.accentLight
                              : palette.textMuted,
                          dot: state.repeat != RepeatMode.off,
                          onTap: player.cycleRepeat,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RepaintBoundary(
                      child: PlaybackPositionBuilder(
                        positionListenable: player.positionListenable,
                        builder: (context, pos) => Row(
                          children: [
                            Text(
                              formatDuration(pos.position),
                              style: AppTextStyles.caption
                                  .copyWith(color: palette.textMuted),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SeekBar(
                                value: pos.progress,
                                buffered: pos.bufferedProgress,
                                onChanged:
                                    pos.duration != null ? player.seek : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatDuration(pos.duration),
                              style: AppTextStyles.caption
                                  .copyWith(color: palette.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Pressable(
                      onTap: onSpeedTap,
                      semanticLabel: 'Kecepatan ${state.speed} kali',
                      child: AppSurface(
                        color: palette.surfaceElevated,
                        borderColor: palette.border,
                        radius: 8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          '${state.speed}×',
                          style: AppTextStyles.label
                              .copyWith(color: palette.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconCircleButton(
                      icon: AppIcons.timer,
                      semanticLabel: 'Timer tidur',
                      size: 36,
                      iconSize: 16,
                      iconColor:
                          (state.sleepAt != null || state.sleepAtEndOfItem)
                              ? palette.accentLight
                              : palette.textMuted,
                      dot: state.sleepAt != null || state.sleepAtEndOfItem,
                      onTap: onSleepTap,
                    ),
                    IconCircleButton(
                      icon: AppIcons.scroll,
                      semanticLabel: 'Antrean (${state.queue.length} item)',
                      size: 36,
                      iconSize: 16,
                      iconColor: palette.textMuted,
                      onTap: onQueueTap,
                    ),
                    IconCircleButton(
                      icon: AppIcons.chevronDown,
                      semanticLabel: 'Perluas pemutar',
                      size: 36,
                      iconSize: 14,
                      iconColor: palette.textMuted,
                      onTap: onExpand,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _repeatLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return 'Ulang mati';
      case RepeatMode.all:
        return 'Ulang semua';
      case RepeatMode.one:
        return 'Ulang satu item';
    }
  }
}
