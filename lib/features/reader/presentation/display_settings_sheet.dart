import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/number_stepper.dart';
import '../../../shared/widgets/pressable.dart';
import '../../player/application/player_controller.dart';
import '../application/reader_controller.dart';
import '../domain/reader_settings.dart';

/// Membuka lembar bawah pengaturan tampilan Reader (docs/06 §3.3, §4.4).
Future<void> showDisplaySettingsSheet(
  BuildContext context, {
  required ReaderController reader,
  required PlayerController player,
  required int currentActiveAyah,
}) {
  return showAppBottomSheet<void>(
    context,
    title: 'Pengaturan Tampilan',
    subtitle: 'Tersimpan otomatis untuk semua surat',
    builder: (context, close) => AnimatedBuilder(
      animation: reader,
      builder: (context, _) {
        final palette = AppThemeScope.paletteOf(context);
        final s = reader.settings;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mode Reader',
              style: AppTextStyles.caption.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SegmentChoice(
                    label: 'Terjemahan',
                    selected: s.mode == ReaderMode.translation,
                    onTap: () => reader.updateSettings(
                      s.copyWith(mode: ReaderMode.translation),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SegmentChoice(
                    label: 'Mode baca',
                    selected: s.mode == ReaderMode.mushaf,
                    onTap: () => reader.updateSettings(
                      s.copyWith(mode: ReaderMode.mushaf),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ukuran huruf Arab (tingkat ${s.arabicSizeLevel}/5)',
              style: AppTextStyles.caption.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 8),
            NumberStepper(
              value: s.arabicSizeLevel,
              min: 1,
              max: 5,
              decreaseLabel: 'Perkecil huruf Arab',
              increaseLabel: 'Perbesar huruf Arab',
              onChanged: (v) => reader.updateSettings(
                s.copyWith(arabicSizeLevel: v),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ukuran terjemahan',
              style: AppTextStyles.caption.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var lvl = 1; lvl <= 3; lvl++) ...[
                  if (lvl > 1) const SizedBox(width: 8),
                  Expanded(
                    child: _SegmentChoice(
                      label: lvl == 1
                          ? 'Kecil'
                          : lvl == 2
                              ? 'Sedang'
                              : 'Besar',
                      selected: s.translationSizeLevel == lvl,
                      onTap: () => reader.updateSettings(
                        s.copyWith(translationSizeLevel: lvl),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _ToggleRow(
              label: 'Tampilkan transliterasi',
              value: s.showTransliteration,
              onTap: () => reader.updateSettings(
                s.copyWith(showTransliteration: !s.showTransliteration),
              ),
            ),
            const SizedBox(height: 8),
            _ToggleRow(
              label: 'Tampilkan terjemahan',
              value: s.showTranslation,
              onTap: () => reader.updateSettings(
                s.copyWith(showTranslation: !s.showTranslation),
              ),
            ),
            const SizedBox(height: 8),
            _ToggleRow(
              label: 'Ikuti ayat otomatis (auto-scroll)',
              value: s.autoScroll,
              onTap: () => reader.updateSettings(
                s.copyWith(autoScroll: !s.autoScroll),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mode sinkronisasi audio',
              style: AppTextStyles.caption.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 8),
            _SegmentChoice(
              label: 'Sorot per ayat (Mode A · akurat)',
              selected: s.syncMode == SyncMode.perAyah,
              onTap: () => unawaited(
                reader.switchSyncMode(
                  SyncMode.perAyah,
                  player,
                  currentActiveAyah: currentActiveAyah,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _SegmentChoice(
              label: 'Audio penuh (Mode B · perkiraan)',
              selected: s.syncMode == SyncMode.fullSurah,
              onTap: () => unawaited(
                reader.switchSyncMode(
                  SyncMode.fullSurah,
                  player,
                  currentActiveAyah: currentActiveAyah,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _SegmentChoice extends StatelessWidget {
  const _SegmentChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: AppSurface(
          color: selected ? palette.surfaceActive : palette.surfaceElevated,
          borderColor: selected ? palette.accent : palette.border,
          radius: 10,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.custom(
                size: 12,
                lineHeight: 17,
                weight: FontWeight.w600,
                color: selected ? palette.accentLight : palette.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Semantics(
      toggled: value,
      child: Pressable(
        onTap: onTap,
        semanticLabel: '$label: ${value ? 'aktif' : 'mati'}',
        child: AppSurface(
          color: palette.surfaceElevated,
          borderColor: palette.border,
          radius: 10,
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.custom(
                    size: 13,
                    lineHeight: 18,
                    weight: FontWeight.w500,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              AppSurface(
                color: value ? palette.accent : palette.surface,
                borderColor: value ? null : palette.border,
                radius: 999,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  value ? 'Ya' : 'Tidak',
                  style: AppTextStyles.micro.copyWith(
                    color: value ? palette.onAccent : palette.textMuted,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
