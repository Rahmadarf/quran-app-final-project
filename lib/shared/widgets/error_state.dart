import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Keadaan galat dual-mode dengan pesan ramah dan tombol "Coba lagi".
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title = 'Gagal memuat data',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              AppIcons.shield,
              size: 36,
              color: palette.danger,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(color: palette.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: palette.textMuted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'Coba lagi',
                style: AppButtonStyle.primary,
                onTap: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
