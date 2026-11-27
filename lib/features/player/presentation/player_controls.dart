import 'package:flutter/widgets.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/icon_circle_button.dart';

/// Baris kontrol utama Fullscreen Player dual-mode:
/// acak, sebelumnya, putar/jeda, berikutnya, ulang.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.playing,
    this.shuffleOn = false,
    this.repeatOne = false,
    this.onShuffle,
    this.onPrevious,
    this.onPlayPause,
    this.onNext,
    this.onRepeat,
    this.previousLabel = 'Ayat sebelumnya',
    this.nextLabel = 'Ayat berikutnya',
  });

  final bool playing;
  final bool shuffleOn;
  final bool repeatOne;
  final VoidCallback? onShuffle;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onRepeat;
  final String previousLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconCircleButton(
            icon: AppIcons.shuffle,
            semanticLabel: shuffleOn ? 'Acak aktif' : 'Acak mati',
            size: 44,
            iconSize: 18,
            iconColor: shuffleOn ? palette.accentLight : palette.textMuted,
            dot: shuffleOn,
            onTap: onShuffle,
          ),
          IconCircleButton(
            icon: AppIcons.previous,
            semanticLabel: previousLabel,
            style: IconCircleStyle.ghost,
            size: 48,
            iconSize: 22,
            iconColor: palette.textPrimary,
            onTap: onPrevious,
          ),
          IconCircleButton(
            icon: playing ? AppIcons.pause : AppIcons.play,
            semanticLabel: playing ? 'Jeda' : 'Putar',
            style: IconCircleStyle.primary,
            size: 64,
            iconSize: 24,
            glow: true,
            onTap: onPlayPause,
          ),
          IconCircleButton(
            icon: AppIcons.next,
            semanticLabel: nextLabel,
            style: IconCircleStyle.ghost,
            size: 48,
            iconSize: 22,
            iconColor: palette.textPrimary,
            onTap: onNext,
          ),
          IconCircleButton(
            icon: repeatOne ? AppIcons.repeatOne : AppIcons.repeat,
            semanticLabel: repeatOne ? 'Ulang satu ayat aktif' : 'Ulang mati',
            size: 44,
            iconSize: 18,
            iconColor: repeatOne ? palette.accentLight : palette.textMuted,
            dot: repeatOne,
            onTap: onRepeat,
          ),
        ],
      ),
    );
  }
}
