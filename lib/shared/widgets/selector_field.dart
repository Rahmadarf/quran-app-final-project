import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

/// Kolom pemilih bergaya dropdown dual-mode.
class SelectorField extends StatelessWidget {
  const SelectorField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: '$label: $value',
      child: AppSurface(
        color: palette.surfaceElevated,
        borderColor: palette.border,
        radius: 10,
        height: 54,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.custom(
                      size: 10,
                      lineHeight: 15,
                      weight: FontWeight.w500,
                      color: palette.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.custom(
                      size: 14,
                      lineHeight: 20,
                      weight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: AppIcon(
                AppIcons.chevronDown,
                size: 9,
                color: palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
