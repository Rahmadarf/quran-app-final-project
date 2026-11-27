import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/number_stepper.dart';

/// Membuka panel "Pilih ayat". Mengembalikan nomor ayat yang dipilih saat
/// "Selesai" diketuk, atau `null` bila ditutup tanpa memilih.
Future<int?> showAyahPicker(
  BuildContext context, {
  required String surahName,
  required int ayahCount,
  required int current,
}) {
  return showAppBottomSheet<int>(
    context,
    title: 'Pilih ayat',
    subtitle: surahName,
    builder: (context, close) => _AyahPickerBody(
      ayahCount: ayahCount,
      initial: current.clamp(1, ayahCount),
      onDone: close,
    ),
  );
}

class _AyahPickerBody extends StatefulWidget {
  const _AyahPickerBody({
    required this.ayahCount,
    required this.initial,
    required this.onDone,
  });

  final int ayahCount;
  final int initial;
  final void Function([int? result]) onDone;

  @override
  State<_AyahPickerBody> createState() => _AyahPickerBodyState();
}

class _AyahPickerBodyState extends State<_AyahPickerBody> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pilih ayat 1–${widget.ayahCount}',
            style: AppTextStyles.custom(
              size: 12,
              lineHeight: 17,
              color: palette.textMuted,
              tabular: true,
            ),
          ),
          const SizedBox(height: 31),
          NumberStepper(
            value: _value,
            min: 1,
            max: widget.ayahCount,
            decreaseLabel: 'Ayat sebelumnya',
            increaseLabel: 'Ayat berikutnya',
            onChanged: (v) => setState(() => _value = v),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Ayat pertama',
                  onTap: () => setState(() => _value = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Ayat terakhir',
                  onTap: () => setState(() => _value = widget.ayahCount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          AppButton(
            label: 'Selesai',
            style: AppButtonStyle.primary,
            height: 50,
            onTap: () => widget.onDone(_value),
          ),
        ],
      ),
    );
  }
}
