import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pressable.dart';

/// Mini Player floating dual-mode sesuai Figma `Obsidian / MiniPlayer`.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.progress = 0,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return Pressable(
      onTap: onTap,
      semanticLabel: 'Sedang diputar: $title, $subtitle. Buka pemutar penuh',
      pressedScale: 0.99,
      pressedOpacity: 0.95,
      child: AppSurface(
        color: palette.surfaceElevated,
        borderColor: palette.borderStrong,
        radius: 16,
        shadows: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: Row(
                  children: [
                    leading,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle
                                .copyWith(color: palette.textPrimary),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption
                                .copyWith(color: palette.textMuted),
                          ),
                        ],
                      ),
                    ),
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      actions[i],
                    ],
                  ],
                ),
              ),
              RepaintBoundary(
                child: _ProgressLine(progress: progress, palette: palette),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress, required this.palette});

  final double progress;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.5,
      child: ColoredBox(
        color: palette.border,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: ColoredBox(
              color: palette.accent,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kotak kecil 40 dp untuk [MiniPlayer.leading]: sampul atau nomor/teks.
class MiniPlayerLeading extends StatelessWidget {
  const MiniPlayerLeading.image(this.image, {super.key})
      : text = null,
        imageAlignment = Alignment.center;

  const MiniPlayerLeading.text(this.text, {super.key})
      : image = null,
        imageAlignment = Alignment.center;

  final ImageProvider? image;
  final String? text;
  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);

    return AppSurface(
      width: 40,
      height: 40,
      radius: 8,
      color: palette.surface,
      borderColor: palette.border,
      child: image != null
          ? Image(
              image: ResizeImage.resizeIfNeeded(120, null, image!),
              fit: BoxFit.cover,
              alignment: imageAlignment,
              excludeFromSemantics: true,
            )
          : Center(
              child: Text(
                text!,
                style: AppTextStyles.arabic(
                  size: 13,
                  lineHeight: 16,
                  weight: FontWeight.w700,
                  color: palette.accentLight,
                ),
              ),
            ),
    );
  }
}
