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

/// Banner ringkas dual-mode sesuai Figma `Obsidian / StatusBanner`.
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
    final bgColor = isOffline ? palette.warningSoft : palette.accentSoft;
    final fgColor = isOffline ? palette.warning : palette.accentLight;

    return Semantics(
      liveRegion: true,
      label: message,
      child: AppSurface(
        color: bgColor,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            AppIcon(
              isOffline ? AppIcons.shield : AppIcons.offlineDone,
              size: 16,
              color: fgColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.label.copyWith(color: fgColor),
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
