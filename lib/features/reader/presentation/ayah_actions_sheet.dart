import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_button.dart';
import '../../quran/domain/ayah.dart';
import '../../quran/domain/surah.dart';

/// Membuka lembar detail & aksi per ayat (dipakai di Mode Baca/Mushaf atau
/// ketuk lama ayat) (docs/06 §3.2, §5).
Future<void> showAyahActionsSheet(
  BuildContext context, {
  required Surah surah,
  required Ayah ayah,
  required bool bookmarked,
  required VoidCallback onPlayFromHere,
  required VoidCallback onToggleBookmark,
  required VoidCallback onOpenTafsir,
}) {
  return showAppBottomSheet<void>(
    context,
    title: '${surah.latinName} · Ayat ${ayah.number}',
    builder: (context, close) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ayah.arabic,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.arabic(
            size: 24,
            lineHeight: 44,
            color: AppColors.sheetText,
          ),
        ),
        if (ayah.transliteration.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            ayah.transliteration.trim(),
            style: AppTextStyles.custom(
              size: 12,
              lineHeight: 18,
              color: AppColors.skyLabel,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          ayah.translation,
          style: AppTextStyles.custom(
            size: 14,
            lineHeight: 21,
            color: AppColors.sheetText,
          ),
        ),
        const SizedBox(height: 18),
        AppButton(
          label: 'Putar dari ayat ini',
          style: AppButtonStyle.primary,
          onTap: () {
            close();
            onPlayFromHere();
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: bookmarked ? 'Hapus penanda' : 'Tandai ayat',
                onTap: () {
                  onToggleBookmark();
                  close();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: 'Baca Tafsir',
                onTap: () {
                  close();
                  onOpenTafsir();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Salin ayat & terjemahan',
          onTap: () async {
            final text =
                '${ayah.arabic}\n\n${ayah.translation}\n(QS ${surah.latinName}: ${ayah.number})';
            await Clipboard.setData(ClipboardData(text: text));
            close();
          },
        ),
      ],
    ),
  );
}
