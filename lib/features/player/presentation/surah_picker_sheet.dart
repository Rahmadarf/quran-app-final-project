import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pressable.dart';

/// Satu pilihan surat. Nama dan jumlah ayat datang dari data (API equran.id).
class SurahOption {
  const SurahOption({
    required this.number,
    required this.name,
    required this.ayahCount,
  });

  final int number;
  final String name;
  final int ayahCount;
}

/// Membuka panel "Pilih surat" dan mengembalikan surat yang diketuk
/// (atau `null` bila ditutup). Daftar bisa digulir.
Future<SurahOption?> showSurahPicker(
  BuildContext context, {
  required List<SurahOption> options,
  required SurahOption selected,
}) {
  return showAppBottomSheet<SurahOption>(
    context,
    title: 'Pilih surat',
    subtitle: selected.name,
    footerHint: 'Scroll untuk melihat surat surat yang lain',
    builder: (context, close) => Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          SurahPickerTile(
            option: options[i],
            selected: options[i].number == selected.number,
            onTap: () => close(options[i]),
          ),
        ],
      ],
    ),
  );
}

/// Baris pilihan surat: nomor, nama, jumlah ayat, dan panah.
class SurahPickerTile extends StatelessWidget {
  const SurahPickerTile({
    super.key,
    required this.option,
    this.selected = false,
    this.onTap,
  });

  final SurahOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel:
            'Surat ${option.number}, ${option.name}, ${option.ayahCount} ayat',
        pressedScale: 0.99,
        child: AppSurface(
          color: AppColors.surfaceCard,
          radius: 10,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              AppSurface(
                color: AppColors.numberBadge,
                radius: 8,
                width: 34,
                height: 32,
                child: Center(
                  child: Text(
                    '${option.number}',
                    style: AppTextStyles.custom(
                      size: 12,
                      lineHeight: 17,
                      weight: FontWeight.w500,
                      color: AppColors.sheetIcon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.custom(
                        size: 13,
                        lineHeight: 19,
                        weight: FontWeight.w600,
                        color: AppColors.sheetText,
                      ),
                    ),
                    Text(
                      '${option.ayahCount} ayat',
                      style: AppTextStyles.custom(
                        size: 10,
                        lineHeight: 15,
                        color: AppColors.sheetMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const AppIcon(
                AppIcons.chevronRight,
                size: 10,
                color: AppColors.sheetIcon,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
