import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';

/// Blok kutipan ayat minimalis dengan garis hairline atas (tanpa kotak berat),
/// sesuai Figma Redesign v2 (`01 — Beranda`).
class QuoteBanner extends StatelessWidget {
  const QuoteBanner({
    super.key,
    required this.quote,
    required this.reference,
  });

  final String quote;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Semantics(
      container: true,
      label: '$quote $reference',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“$quote”',
                  style: AppTextStyles.quote
                      .copyWith(color: palette.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  reference,
                  style: AppTextStyles.labelStrong
                      .copyWith(color: palette.accentLight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
