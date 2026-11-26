import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/player_controller.dart';

/// Membuka lembar bawah Timer Tidur (5–60 menit atau akhir item) (docs/05 §4).
Future<void> showSleepTimerSheet(
  BuildContext context,
  PlayerController player,
) {
  const presets = [5, 10, 15, 30, 45, 60];
  final state = player.state;
  final hasTimer = state.sleepAt != null || state.sleepAtEndOfItem;

  String subtitle;
  if (state.sleepAtEndOfItem) {
    subtitle = 'Berhenti di akhir bacaan saat ini';
  } else if (state.sleepAt != null) {
    final rem = state.sleepAt!.difference(DateTime.now());
    final mins = rem.inMinutes.clamp(0, 999);
    subtitle = 'Aktif · sekitar $mins menit tersisa';
  } else {
    subtitle = 'Otomatis menjeda pemutaran dengan pudar halus';
  }

  return showAppBottomSheet<void>(
    context,
    title: 'Timer Tidur',
    subtitle: subtitle,
    builder: (context, close) => Column(
      children: [
        for (var i = 0; i < presets.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _SleepOptionTile(
            label: '${presets[i]} menit',
            selected: false,
            onTap: () {
              player.setSleepTimer(Duration(minutes: presets[i]));
              close();
            },
          ),
        ],
        const SizedBox(height: 8),
        _SleepOptionTile(
          label: 'Akhir item saat ini',
          selected: state.sleepAtEndOfItem,
          onTap: () {
            player.setSleepTimer(null, endOfItem: true);
            close();
          },
        ),
        if (hasTimer) ...[
          const SizedBox(height: 8),
          _SleepOptionTile(
            label: 'Matikan timer',
            selected: false,
            destructive: true,
            onTap: () {
              player.setSleepTimer(null, endOfItem: false);
              close();
            },
          ),
        ],
      ],
    ),
  );
}

class _SleepOptionTile extends StatelessWidget {
  const _SleepOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final bool selected;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AppSurface(
        color: selected ? AppColors.surfaceStrong : AppColors.surfaceCard,
        borderColor: selected ? AppColors.accent : null,
        radius: 12,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: AppTextStyles.custom(
              size: 13,
              lineHeight: 18,
              weight: FontWeight.w600,
              color: destructive
                  ? const Color(0xFFF87171)
                  : selected
                      ? AppColors.accentLight
                      : AppColors.sheetText,
            ),
          ),
        ),
      ),
    );
  }
}
