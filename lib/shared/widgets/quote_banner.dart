import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';

/// Banner kutipan ayat di Beranda: ikon kutip, teks miring, dan rujukan tebal.
class QuoteBanner extends StatelessWidget {
  const QuoteBanner({
    super.key,
    required this.quote,
    required this.reference,
  });

  final String quote;

  /// Rujukan ayat, mis. "QS. Ar-Ra'd : 28".
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$quote $reference',
      child: ExcludeSemantics(
        child: AppSurface(
          color: AppColors.surfaceAt(0.8),
          borderColor: AppColors.border,
          radius: 12,
          shadows: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              const AppIcon(AppIcons.quote, size: 16, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.custom(
                      size: 12,
                      lineHeight: 16.5,
                      style: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                    children: [
                      TextSpan(text: '"$quote" '),
                      TextSpan(
                        text: reference,
                        style: AppTextStyles.custom(
                          size: 12,
                          lineHeight: 16.5,
                          weight: FontWeight.w600,
                          color: AppColors.accentLight,
                        ).copyWith(fontStyle: FontStyle.normal),
                      ),
                    ],
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
