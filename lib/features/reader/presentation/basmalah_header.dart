import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';

/// Kepala Basmalah bersih dual-mode (hairline divider) sesuai Figma `03 — Quran Reader`.
class BasmalahHeader extends StatelessWidget {
  const BasmalahHeader({
    super.key,
    required this.arabic,
    required this.translation,
  });

  final String arabic;
  final String translation;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Semantics(
      container: true,
      label: 'Basmalah. $translation',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.arabic(
                      size: 28,
                      lineHeight: 58,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    translation,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption
                        .copyWith(color: palette.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
