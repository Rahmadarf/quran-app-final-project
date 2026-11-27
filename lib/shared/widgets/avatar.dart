import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'pressable.dart';

/// Foto bulat dual-mode dengan cincin dan (opsional) titik status.
class AvatarRing extends StatelessWidget {
  const AvatarRing({
    super.key,
    required this.image,
    this.size = 40,
    this.ringWidth = 1.5,
    this.ringColor,
    this.onlineDot = false,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  final ImageProvider image;
  final double size;
  final double ringWidth;
  final Color? ringColor;
  final bool onlineDot;
  final Alignment alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final effectiveRing = ringColor ?? palette.borderStrong;
    final total = size + ringWidth * 2;

    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox(
        width: total,
        height: total,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.surface,
                border: Border.all(color: effectiveRing, width: ringWidth),
              ),
              child: ClipOval(
                child: Image(
                  image: ResizeImage.resizeIfNeeded(
                    (size * 3).round(),
                    null,
                    image,
                  ),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  alignment: alignment,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            if (onlineDot)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: palette.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.background, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Qari bulat dual-mode dengan cincin emerald saat terpilih (`Obsidian / QariAvatar`).
class QariAvatarItem extends StatelessWidget {
  const QariAvatarItem({
    super.key,
    required this.image,
    required this.name,
    this.selected = false,
    this.onTap,
    this.alignment = Alignment.center,
  });

  final ImageProvider image;
  final String name;
  final bool selected;
  final VoidCallback? onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: 'Qari $name',
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.surface,
                border: Border.all(
                  color: selected ? palette.borderAccent : palette.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: ClipOval(
                child: Image(
                  image: ResizeImage.resizeIfNeeded(180, null, image),
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  alignment: alignment,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: selected ? palette.accentLight : palette.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar bulat berisi inisial untuk qari tanpa foto.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.fontSize = 13,
  });

  final String initials;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.accent,
          shape: BoxShape.circle,
        ),
        child: Text(
          initials,
          style: AppTextStyles.custom(
            size: fontSize,
            lineHeight: fontSize + 6,
            weight: FontWeight.w600,
            color: palette.onAccent,
          ),
        ),
      ),
    );
  }
}
