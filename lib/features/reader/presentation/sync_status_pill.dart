import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_surface.dart';

/// Pil status sinkronisasi audio-ayat dual-mode sesuai Figma `Obsidian / SyncPill`.
class SyncStatusPill extends StatelessWidget {
  const SyncStatusPill({
    super.key,
    this.label = 'Sinkronisasi Ayat Otomatis',
    this.isEstimated = false,
  });

  final String label;
  final bool isEstimated;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final bg = isEstimated ? palette.warningSoft : palette.accentSoft;
    final border = isEstimated ? palette.warning : palette.borderAccent;
    final fg = isEstimated ? palette.warning : palette.accentLight;

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: AppSurface(
          color: bg,
          borderColor: border,
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: fg,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 7, height: 7),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
