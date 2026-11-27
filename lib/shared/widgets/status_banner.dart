import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pill_button.dart';

/// Jenis status banner untuk layar daftar surat dan Reader (docs/07 §0.4, §4).
enum StatusBannerKind {
  offline,
  stale,
  info,
}

/// Banner ringkas untuk menandakan mode offline atau data tersimpan (cache).
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.kind,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final StatusBannerKind kind;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final isOffline = kind == StatusBannerKind.offline;
    final bgColor = isOffline
        ? (palette.isDark
            ? const Color(0x33F59E0B)
            : const Color(0xFFFEF3C7))
        : palette.surfaceActive;
    final borderColor = isOffline
        ? (palette.isDark
            ? const Color(0x66F59E0B)
            : const Color(0xFFF59E0B))
        : palette.border;
    final iconColor = isOffline
        ? (palette.isDark
            ? const Color(0xFFFCD34D)
            : const Color(0xFFB45309))
        : palette.accentLight;

    return Semantics(
      liveRegion: true,
      label: message,
      child: AppSurface(
        color: bgColor,
        borderColor: borderColor,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            AppIcon(
              isOffline ? AppIcons.shield : AppIcons.offlineDone,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(
                  color: palette.textPrimary,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 8),
              PillButton(
                label: actionLabel!,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                onTap: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
