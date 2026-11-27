import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/constants.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/player_controller.dart';

/// Membuka lembar bawah pengatur kecepatan pemutaran (docs/05 §4).
Future<void> showSpeedSheet(
  BuildContext context,
  PlayerController player,
) {
  final currentSpeed = player.state.speed;
  return showAppBottomSheet<void>(
    context,
    title: 'Kecepatan Putar',
    subtitle: 'Saat ini $currentSpeed×',
    builder: (context, close) => Column(
      children: [
        for (var i = 0; i < AppConstants.playbackSpeeds.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _SpeedTile(
            speed: AppConstants.playbackSpeeds[i],
            selected: (AppConstants.playbackSpeeds[i] - currentSpeed).abs() < 0.01,
            onTap: () {
              player.setSpeed(AppConstants.playbackSpeeds[i]);
              close();
            },
          ),
        ],
      ],
    ),
  );
}

class _SpeedTile extends StatelessWidget {
  const _SpeedTile({
    required this.speed,
    required this.selected,
    required this.onTap,
  });

  final double speed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final label = speed == 1.0 ? '1.0× (Normal)' : '$speed×';
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: 'Kecepatan $label',
        child: AppSurface(
          color: selected ? palette.surfaceActive : palette.surfaceElevated,
          borderColor: selected ? palette.accent : palette.border,
          radius: 12,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.custom(
                    size: 13,
                    lineHeight: 18,
                    weight: FontWeight.w600,
                    color: selected ? palette.accentLight : palette.textPrimary,
                    tabular: true,
                  ),
                ),
              ),
              if (selected)
                AppIcon(
                  AppIcons.check,
                  size: 14,
                  color: palette.accentLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
