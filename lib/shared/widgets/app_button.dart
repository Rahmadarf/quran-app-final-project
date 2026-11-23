import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_surface.dart';
import 'pressable.dart';

enum AppButtonStyle {
  /// Isi terang, tulisan gelap: aksi utama ("Selesai").
  primary,

  /// Isi gelap kebiruan, tulisan krem: aksi sekunder ("Ayat pertama").
  tonal,
}

/// Tombol persegi membulat selebar induknya.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.style = AppButtonStyle.tonal,
    this.height = 42,
  });

  final String label;
  final VoidCallback? onTap;
  final AppButtonStyle style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final primary = style == AppButtonStyle.primary;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AppSurface(
        color: primary ? AppColors.accentLight : AppColors.surfaceCard,
        radius: 12,
        height: height,
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.custom(
              size: 14,
              lineHeight: 20,
              weight: FontWeight.w600,
              color: primary ? AppColors.surfaceCard : AppColors.sheetText,
            ),
          ),
        ),
      ),
    );
  }
}
