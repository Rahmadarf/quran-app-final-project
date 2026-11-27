import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme.dart';

/// Kerangka pemuatan dual-mode dengan efek kilau halus (`flutter_animate`).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 12,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.paletteOf(context);
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final box = ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceElevated,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );

    if (disableAnim) return box;

    return box
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1400.ms,
          color: palette.isDark
              ? const Color(0x14FFFFFF)
              : const Color(0x66FFFFFF),
        );
  }
}
