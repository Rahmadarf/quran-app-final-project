import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/selector_field.dart';

/// Kartu pemilih ringkas dual-mode di dasar Fullscreen Player: qari, surat, ayat.
class PlaybackSelectorCard extends StatelessWidget {
  const PlaybackSelectorCard({
    super.key,
    required this.qariName,
    required this.surahName,
    required this.ayahNumber,
    this.qariAvatar,
    this.onQariTap,
    this.onSurahTap,
    this.onAyahTap,
  });

  final String qariName;
  final String surahName;
  final int ayahNumber;
  final Widget? qariAvatar;
  final VoidCallback? onQariTap;
  final VoidCallback? onSurahTap;
  final VoidCallback? onAyahTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return AppSurface(
      color: palette.surface,
      borderColor: palette.border,
      radius: 16,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pressable(
            onTap: onQariTap,
            semanticLabel: 'Buka pilihan qari. Saat ini $qariName',
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  qariAvatar ?? _initialsAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QARI',
                          style: AppTextStyles.micro
                              .copyWith(color: palette.accentLight),
                        ),
                        Text(
                          qariName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 14,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIcon(
                    AppIcons.chevronRight,
                    size: 11,
                    color: palette.textMuted,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 220,
                child: SelectorField(
                  label: 'Pilih Surat',
                  value: surahName,
                  onTap: onSurahTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 106,
                child: SelectorField(
                  label: 'Ayat',
                  value: '$ayahNumber',
                  onTap: onAyahTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar() {
    final parts = qariName.trim().split(RegExp(r'\s+'));
    final initials = parts.length == 1
        ? parts.first.substring(0, 1)
        : '${parts.first[0]}${parts[1][0]}';
    return InitialsAvatar(
      initials: initials.toUpperCase(),
      size: 40,
      fontSize: 13,
    );
  }
}
