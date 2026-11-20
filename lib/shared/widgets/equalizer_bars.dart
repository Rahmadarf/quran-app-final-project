import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../app/app_colors.dart';

/// Tiga batang penanda "sedang memutar". Bergerak saat [playing] true.
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({
    super.key,
    this.playing = true,
    this.color = AppColors.accentLight,
    this.height = 12,
  });

  final bool playing;
  final Color color;
  final double height;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.playing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.playing) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(10, widget.height),
          painter: _BarsPainter(_controller, widget.color),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.animation, this.color) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  // Tinggi relatif diam: 6 / 12 / 8 dari 12 (sesuai Figma).
  static const _rest = [0.5, 1.0, 0.67];
  static const _phase = [0.0, 0.33, 0.66];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const barWidth = 2.0;
    final gap = (size.width - barWidth * 3) / 2;
    for (var i = 0; i < 3; i++) {
      final wave = animation.isAnimating
          ? 0.55 + 0.45 * math.sin((animation.value + _phase[i]) * 2 * math.pi)
          : _rest[i];
      final h = size.height * wave.clamp(0.25, 1.0);
      final x = i * (barWidth + gap);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, barWidth, h),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) => old.color != color;
}
