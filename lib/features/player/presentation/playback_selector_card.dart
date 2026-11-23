import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/selector_field.dart';

/// Kartu pemilih ringkas di dasar pemutar: baris qari di atas, lalu dua
/// kolom pemilih surat dan ayat. Tiap bagian membuka panel pilihannya.
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

  /// Avatar qari (foto atau inisial). Bila kosong, dibuat dari nama.
  final Widget? qariAvatar;
  final VoidCallback? onQariTap;
  final VoidCallback? onSurahTap;
  final VoidCallback? onAyahTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      color: AppColors.sheet,
      borderColor: AppColors.border,
      blur: 12,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pressable(
            onTap: onQariTap,
            semanticLabel: 'Buka pilihan qari. Saat ini $qariName',
            child: SizedBox(
              height: 60,
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
                          style: AppTextStyles.custom(
                            size: 10,
                            lineHeight: 15,
                            weight: FontWeight.w600,
                            color: AppColors.sheetIcon,
                          ),
                        ),
                        Text(
                          qariName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.custom(
                            size: 13,
                            lineHeight: 19,
                            weight: FontWeight.w600,
                            color: AppColors.sheetText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppIcon(
                    AppIcons.chevronRight,
                    size: 11,
                    color: AppColors.sheetIcon,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
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
      size: 44,
      fontSize: 14,
    );
  }
}
