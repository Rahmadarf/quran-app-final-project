import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_icon.dart';
import 'app_surface.dart';
import 'badge_chip.dart';
import 'icon_circle_button.dart';
import 'pressable.dart';

/// Gambar mini persegi membulat (sampul playlist) atau kotak ikon.
class MediaThumb extends StatelessWidget {
  const MediaThumb({
    super.key,
    this.image,
    this.icon,
    this.size = 56,
    this.radius = 8,
    this.overlayIcon,
    this.background,
  }) : assert(image != null || icon != null);

  final ImageProvider? image;

  /// Dipakai bila tidak ada gambar (mis. ikon podcast di atas gradasi biru).
  final AppIcons? icon;
  final double size;
  final double radius;

  /// Ikon kecil di pojok (mis. penanda "terunduh").
  final AppIcons? overlayIcon;
  final Gradient? background;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      width: size,
      height: size,
      radius: radius,
      color: AppColors.surface,
      gradient: image == null
          ? (background ??
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceStrong, AppColors.accent],
              ))
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image(
              image: image!,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            )
          else
            Center(
              child: AppIcon(
                icon!,
                size: size * 0.43,
                color: AppColors.accentLight,
              ),
            ),
          if (overlayIcon != null)
            Positioned(
              right: 4,
              bottom: 4,
              child: AppIcon(
                overlayIcon!,
                size: 11,
                color: AppColors.accentLight,
              ),
            ),
        ],
      ),
    );
  }
}

/// Baris daftar playlist: gambar, judul (+ penanda), keterangan, tagar, menu.
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

  /// Ikon hati biru di samping judul.
  final bool favorite;

  /// Lencana "OFFLINE" di samping judul.
  final bool offline;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '$title, $subtitle',
      pressedScale: 0.99,
      child: AppSurface(
        color: AppColors.surfaceDeep,
        borderColor: AppColors.borderAt(0.2),
        radius: 12,
        padding: const EdgeInsets.all(13),
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
                          style: AppTextStyles.rowTitle,
                        ),
                      ),
                      if (favorite) ...[
                        const SizedBox(width: 6),
                        const AppIcon(
                          AppIcons.heartFilled,
                          size: 12,
                          color: AppColors.accent,
                        ),
                      ],
                      if (offline) ...[
                        const SizedBox(width: 6),
                        BadgeChip.status('OFFLINE'),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textFaint),
                  ),
                  if (tagline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        tagline!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.micro,
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
                iconColor: AppColors.placeholder,
                onTap: onMore,
              ),
          ],
        ),
      ),
    );
  }
}
