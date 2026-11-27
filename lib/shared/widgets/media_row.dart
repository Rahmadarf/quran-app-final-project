import 'package:flutter/widgets.dart';

import '../../app/app_text_styles.dart';
import '../../app/theme.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'icon_circle_button.dart';
import 'pressable.dart';

/// Gambar mini persegi membulat (sampul playlist) atau kotak ikon.
class MediaThumb extends StatelessWidget {
  const MediaThumb({
    super.key,
    this.image,
    this.icon,
    this.size = 48,
    this.radius = 8,
    this.overlayIcon,
    this.background,
  }) : assert(image != null || icon != null);

  final ImageProvider? image;
  final AppIcons? icon;
  final double size;
  final double radius;
  final AppIcons? overlayIcon;
  final Gradient? background;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return AppSurface(
      width: size,
      height: size,
      radius: radius,
      color: palette.surfaceElevated,
      borderColor: palette.border,
      gradient: image == null ? background : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image(
              image: ResizeImage.resizeIfNeeded(
                (size * 3).round(),
                null,
                image!,
              ),
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            )
          else
            Center(
              child: AppIcon(
                icon!,
                size: size * 0.42,
                color: palette.accentLight,
              ),
            ),
          if (overlayIcon != null)
            Positioned(
              right: 4,
              bottom: 4,
              child: AppIcon(
                overlayIcon!,
                size: 11,
                color: palette.accentLight,
              ),
            ),
        ],
      ),
    );
  }
}

/// Baris daftar playlist zero-card hairline sesuai Figma `Obsidian / PlaylistRow`.
class MediaRow extends StatelessWidget {
  const MediaRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.tagline,
    this.favorite = false,
    this.offline = false,
    this.onTap,
    this.onMore,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String? tagline;
  final bool favorite;
  final bool offline;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: '$title, $subtitle',
      pressedScale: 0.99,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.rowTitle
                                .copyWith(color: palette.textPrimary),
                          ),
                        ),
                        if (favorite) ...[
                          const SizedBox(width: 6),
                          AppIcon(
                            AppIcons.heartFilled,
                            size: 13,
                            color: palette.accent,
                          ),
                        ],
                        if (offline) ...[
                          const SizedBox(width: 6),
                          AppIcon(
                            AppIcons.offlineDone,
                            size: 15,
                            color: palette.accent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption
                          .copyWith(color: palette.textMuted),
                    ),
                    if (tagline != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          tagline!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: palette.textSubtle,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (onMore != null)
                IconCircleButton(
                  icon: AppIcons.moreVert,
                  semanticLabel: 'Opsi $title',
                  size: 32,
                  iconSize: 14,
                  iconColor: palette.textMuted,
                  onTap: onMore,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
