import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';

/// Kerangka pemuatan berbentuk persegi panjang membulat (docs/07 §0.4, §4).
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
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceAt(0.55),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
