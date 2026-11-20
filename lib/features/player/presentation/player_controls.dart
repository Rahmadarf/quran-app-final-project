import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/icon_circle_button.dart';

/// Baris kontrol utama Fullscreen Player:
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

  /// Mode ulang satu ayat aktif: ikon "ulang 1" plus titik penanda.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconCircleButton(
            icon: AppIcons.shuffle,
            semanticLabel: shuffleOn ? 'Acak aktif' : 'Acak mati',
            size: 44,
            iconSize: 16,
            iconColor: shuffleOn ? AppColors.accentLight : AppColors.textBody,
            dot: shuffleOn,
            onTap: onShuffle,
          ),
          IconCircleButton(
            icon: AppIcons.previous,
            semanticLabel: previousLabel,
            style: IconCircleStyle.glass,
            size: 48,
            iconSize: 16,
            iconColor: AppColors.textMuted,
            onTap: onPrevious,
          ),
          IconCircleButton(
            icon: playing ? AppIcons.pause : AppIcons.play,
            semanticLabel: playing ? 'Jeda' : 'Putar',
            style: IconCircleStyle.primary,
            size: 72,
            iconSize: 22,
            glow: true,
            onTap: onPlayPause,
          ),
          IconCircleButton(
            icon: AppIcons.next,
            semanticLabel: nextLabel,
            style: IconCircleStyle.glass,
            size: 48,
            iconSize: 16,
            iconColor: AppColors.textMuted,
            onTap: onNext,
          ),
          IconCircleButton(
            icon: repeatOne ? AppIcons.repeatOne : AppIcons.repeat,
            semanticLabel: repeatOne ? 'Ulang satu ayat aktif' : 'Ulang mati',
            size: 44,
            iconSize: 18,
            iconColor: repeatOne ? AppColors.accentLight : AppColors.textBody,
            dot: repeatOne,
            onTap: onRepeat,
          ),
        ],
      ),
    );
  }
}
