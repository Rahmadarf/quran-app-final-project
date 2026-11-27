import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Pemilih angka: tombol kurang, angka besar di tengah, tombol tambah.
/// Nilai dibatasi ke [min]..[max]; tombol di batas ikut nonaktif.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.decreaseLabel = 'Kurangi',
    this.increaseLabel = 'Tambah',
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String decreaseLabel;
  final String increaseLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Semantics(
      container: true,
      label: 'Nilai $value dari $min sampai $max',
      child: Row(
        children: [
          _StepButton(
            glyph: '−',
            label: decreaseLabel,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: AppTextStyles.custom(
                  size: 42,
                  lineHeight: 61,
                  weight: FontWeight.w600,
                  color: palette.textPrimary,
                  tabular: true,
                ),
              ),
            ),
          ),
          _StepButton(
            glyph: '+',
            label: increaseLabel,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.glyph,
    required this.label,
    required this.onTap,
  });

  final String glyph;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: AppSurface(
          color: palette.surfaceElevated,
          borderColor: palette.border,
          radius: 12,
          width: 64,
          height: 64,
          child: Center(
            child: Text(
              glyph,
              style: AppTextStyles.custom(
                size: 22,
                lineHeight: 26,
                weight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
