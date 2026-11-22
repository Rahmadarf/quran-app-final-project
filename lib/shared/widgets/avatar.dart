import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'pressable.dart';

/// Foto bulat dengan cincin dan (opsional) titik status.
class AvatarRing extends StatelessWidget {
  const AvatarRing({
    super.key,
    required this.image,
    this.size = 40,
    this.ringWidth = 2,
    this.ringColor = AppColors.accent,
    this.onlineDot = false,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  final ImageProvider image;

  /// Diameter foto (cincin digambar di luarnya).
  final double size;
  final double ringWidth;
  final Color? ringColor;
  final bool onlineDot;
  final Alignment alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final total = size + (ringColor == null ? 0 : ringWidth * 2);
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
                color: AppColors.surface,
                border: ringColor == null
                    ? null
                    : Border.all(color: ringColor!, width: ringWidth),
              ),
              child: ClipOval(
                child: Image(
                  image: image,
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
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Qari bulat dengan nama di bawah (rak "Qari Favorit").
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
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Qari $name',
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: ClipOval(
                child: Image(
                  image: image,
                  width: 56,
                  height: 56,
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
              style: AppTextStyles.captionMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar bulat berisi inisial (mis. "AS") untuk qari tanpa foto.
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
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accentLight,
          shape: BoxShape.circle,
        ),
        child: Text(
          initials,
          style: AppTextStyles.custom(
            size: fontSize,
            lineHeight: fontSize + 6,
            weight: FontWeight.w600,
            color: AppColors.sheet,
          ),
        ),
      ),
    );
  }
}
