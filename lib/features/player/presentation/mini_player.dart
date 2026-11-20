import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/pressable.dart';

/// Mini Player: kartu kaca di atas bilah navigasi dengan garis progres tipis.
///
/// Slot [leading] dan [actions] dibuat bebas karena isinya berbeda per layar
/// (Beranda: hati + putar; Jelajah: putar + lanjut; Reader: nomor ayat).
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

  /// 0..1. Posisi putar saat ini terhadap durasi.
  final double progress;

  /// Membuka Fullscreen Player.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Sedang diputar: $title, $subtitle. Buka pemutar penuh',
      pressedScale: 0.99,
      pressedOpacity: 0.95,
      child: AppSurface(
        color: AppColors.surfaceAt(0.95),
        borderColor: AppColors.border,
        blur: 24,
        radius: 12,
        height: 54,
        shadows: const [
          BoxShadow(
            color: Color(0x99001233), // rgba(0,18,51,0.6)
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    leading,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
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
            ),
            _ProgressLine(progress: progress),
          ],
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.4,
      child: ColoredBox(
        color: const Color(0xFF001A43),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(999)),
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kotak kecil 36 dp untuk [MiniPlayer.leading]: sampul atau nomor/teks.
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
    return AppSurface(
      width: 36,
      height: 36,
      radius: 8,
      color: AppColors.background,
      borderColor: image != null ? AppColors.accent : AppColors.borderAt(0.6),
      child: image != null
          ? Image(
              image: image!,
              fit: BoxFit.cover,
              alignment: imageAlignment,
              excludeFromSemantics: true,
            )
          : Center(
              child: Text(
                text!,
                style: AppTextStyles.arabic(
                  size: 12,
                  lineHeight: 16,
                  weight: FontWeight.w700,
                  color: AppColors.accentLight,
                ),
              ),
            ),
    );
  }
}
