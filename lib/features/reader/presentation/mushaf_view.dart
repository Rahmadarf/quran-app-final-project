import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../quran/domain/ayah.dart';

/// Tata letak Mode Baca (Mushaf) mengalir dalam satu blok RTL dengan penanda
/// akhir ayat `۝` di luar string teks Arab API (docs/06 §3.2, §6).
class MushafView extends StatefulWidget {
  const MushafView({
    super.key,
    required this.ayat,
    required this.arabicFontSize,
    this.activeAyah,
    required this.onAyahTap,
  });

  final List<Ayah> ayat;
  final double arabicFontSize;
  final int? activeAyah;
  final ValueChanged<Ayah> onAyahTap;

  @override
  State<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<MushafView> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final baseStyle = AppTextStyles.arabic(
      size: widget.arabicFontSize,
      lineHeight: widget.arabicFontSize * 2.05,
      color: AppColors.textPrimary,
    );

    final spans = <InlineSpan>[];
    for (var i = 0; i < widget.ayat.length; i++) {
      final ayah = widget.ayat[i];
      final isActive = ayah.number == widget.activeAyah;
      final recognizer = TapGestureRecognizer()
        ..onTap = () => widget.onAyahTap(ayah);
      _recognizers.add(recognizer);

      spans.add(
        TextSpan(
          text: ayah.arabic,
          recognizer: recognizer,
          style: isActive
              ? baseStyle.copyWith(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w700,
                  backgroundColor: AppColors.surfaceActive,
                )
              : baseStyle,
        ),
      );

      spans.add(
        TextSpan(
          text: ' \u06DD${_arabicDigits(ayah.number)} ',
          recognizer: recognizer,
          style: baseStyle.copyWith(
            fontSize: widget.arabicFontSize * 0.78,
            color: isActive ? AppColors.accentLight : AppColors.accent,
          ),
        ),
      );
    }

    return Semantics(
      label: 'Mode baca Al-Qur\'an. Ketuk ayat untuk melihat terjemahan dan tafsir.',
      child: AppSurface(
        color: AppColors.surfaceVerse,
        borderColor: AppColors.borderAt(0.35),
        radius: 14,
        padding: const EdgeInsets.all(18),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text.rich(
            TextSpan(children: spans),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }

  static String _arabicDigits(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return '$n'.split('').map((c) => digits[int.parse(c)]).join();
  }
}
