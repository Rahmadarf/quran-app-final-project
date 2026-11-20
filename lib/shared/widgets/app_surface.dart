import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

/// Permukaan dasar: kotak membulat dengan isi, garis tepi, bayangan, dan
/// (opsional) blur latar. Semua kartu, chip, dan panel dibangun dari sini.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    this.child,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1,
    this.radius = 12,
    this.shape = BoxShape.rectangle,
    this.shadows,
    this.blur = 0,
    this.padding,
    this.width,
    this.height,
    this.clip = true,
  });

  final Widget? child;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final BoxShape shape;
  final List<BoxShadow>? shadows;

  /// Sigma blur untuk latar di belakang permukaan (0 = tanpa blur).
  final double blur;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// Potong isi mengikuti bentuk. Matikan bila isi sengaja meluap (glow).
  final bool clip;

  BorderRadius? get _borderRadius =>
      shape == BoxShape.circle ? null : BorderRadius.circular(radius);

  @override
  Widget build(BuildContext context) {
    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        shape: shape,
        borderRadius: _borderRadius,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
        boxShadow: shadows,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    if (blur > 0) {
      // Blur harus dipotong; bayangan digambar di luar potongan.
      content = DecoratedBox(
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: _borderRadius,
          boxShadow: shadows,
        ),
        child: _clipped(
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                gradient: gradient,
                shape: shape,
                borderRadius: _borderRadius,
                border: borderColor == null
                    ? null
                    : Border.all(color: borderColor!, width: borderWidth),
              ),
              child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ),
          ),
        ),
      );
    } else if (clip) {
      content = _clipped(content);
    }

    if (width != null || height != null) {
      content = SizedBox(width: width, height: height, child: content);
    }
    return content;
  }

  Widget _clipped(Widget w) => shape == BoxShape.circle
      ? ClipOval(child: w)
      : ClipRRect(borderRadius: BorderRadius.circular(radius), child: w);
}
