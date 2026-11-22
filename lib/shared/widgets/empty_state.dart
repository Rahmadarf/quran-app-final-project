import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pill_button.dart';

/// Keadaan kosong: ikon, judul, satu kalimat, dan satu tombol (docs/07 §4).
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSurface(
              shape: BoxShape.circle,
              color: AppColors.surface,
              borderColor: AppColors.borderAt(0.5),
              width: 72,
              height: 72,
              child: Center(
                child: AppIcon(icon, size: 28, color: AppColors.accentLight),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardHeading,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
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
