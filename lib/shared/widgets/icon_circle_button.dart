import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'pressable.dart';

enum IconCircleStyle {
  /// Tanpa latar.
  ghost,

  /// Latar `surface` polos.
  tonal,

  /// Latar `surface` dengan garis tepi (tombol cari di header).
  outlined,

  /// Latar terang (`accentLight`) untuk aksi utama seperti putar/jeda.
  primary,

  /// Kaca: latar transparan dengan blur (tombol di Fullscreen Player).
  glass,
}

/// Tombol bulat berisi satu ikon.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.size = 40,
    this.iconSize,
    this.style = IconCircleStyle.ghost,
    this.iconColor,
    this.glow = false,
    this.dot = false,
  });

  final AppIcons icon;

  /// Wajib: tombol ikon harus punya nama untuk pembaca layar.
  final String semanticLabel;
  final VoidCallback? onTap;
  final double size;
  final double? iconSize;
  final IconCircleStyle style;
  final Color? iconColor;

  /// Cahaya biru di bawah tombol (tombol putar besar).
  final bool glow;

  /// Titik kecil penanda "aktif" di bawah ikon (mode ulang).
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final isPrimary = style == IconCircleStyle.primary;
    final color = iconColor ??
        (isPrimary ? AppColors.onLight : AppColors.textMuted);

    Widget glyph = AppIcon(icon, size: iconSize ?? size * 0.4, color: color);
    if (dot) {
      glyph = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          glyph,
          Positioned(
            bottom: -(size * 0.2),
            child: const SizedBox(
              width: 4,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final surface = switch (style) {
      IconCircleStyle.ghost => AppSurface(
          shape: BoxShape.circle,
          width: size,
          height: size,
          clip: false,
          child: Center(child: glyph),
        ),
      IconCircleStyle.tonal => AppSurface(
          shape: BoxShape.circle,
          color: AppColors.surface,
          width: size,
          height: size,
          child: Center(child: glyph),
        ),
      IconCircleStyle.outlined => AppSurface(
          shape: BoxShape.circle,
          color: AppColors.surface,
          borderColor: AppColors.borderAt(0.5),
          width: size,
          height: size,
          child: Center(child: glyph),
        ),
      IconCircleStyle.primary => AppSurface(
          shape: BoxShape.circle,
          color: AppColors.accentLight,
          width: size,
          height: size,
          clip: false,
          shadows: glow
              ? [
                  BoxShadow(
                    color: AppColors.accentAt(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
          child: Center(child: glyph),
        ),
      IconCircleStyle.glass => AppSurface(
          shape: BoxShape.circle,
          color: AppColors.surfaceAt(0.8),
          borderColor: AppColors.borderAt(0.5),
          blur: 12,
          width: size,
          height: size,
          child: Center(child: glyph),
        ),
    };

    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: surface,
    );
  }
}
