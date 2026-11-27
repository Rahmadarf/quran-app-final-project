import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pill_button.dart';

/// Keadaan kosong dual-mode: ikon, judul, satu kalimat, dan satu tombol.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final AppIcons icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSurface(
              shape: BoxShape.circle,
              color: palette.surface,
              borderColor: palette.border,
              width: 68,
              height: 68,
              child: Center(
                child: AppIcon(icon, size: 26, color: palette.accentLight),
              ),
            ),
            const SizedBox(height: 16),
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
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              PillButton(
                label: actionLabel,
                style: PillButtonStyle.highlight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: AppTextStyles.label,
                onTap: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
