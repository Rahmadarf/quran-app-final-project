import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_surface.dart';

/// Pil kecil melayang di atas Mini Player Reader yang memberi tahu bahwa
/// sorotan ayat sedang mengikuti audio. Untuk mode "perkiraan" (docs/06 §4.2)
/// ganti [label] menjadi "Sorotan perkiraan".
class SyncStatusPill extends StatelessWidget {
  const SyncStatusPill({
    super.key,
    this.label = 'Sinkronisasi Ayat Otomatis',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: AppSurface(
          color: AppColors.surfaceAt(0.95),
          borderColor: AppColors.border,
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shadows: const [
            BoxShadow(
              color: Color(0x66000D29),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.lightAt(0.7), blurRadius: 6),
                  ],
                ),
                child: const SizedBox(width: 8, height: 8),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.accentLight,
                    letterSpacing: 0,
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
