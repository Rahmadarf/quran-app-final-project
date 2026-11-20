import 'package:flutter/widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';

/// Bilah geser pemutar yang digambar sendiri: lintasan, buffer, progres
/// bergradasi, dan pegangan bercahaya. Bisa diketuk atau diseret.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.value,
    this.buffered = 0,
    this.onChanged,
    this.onChangeEnd,
    this.semanticLabel = 'Posisi pemutaran',
    this.semanticValue,
  });

  /// Posisi 0..1.
  final double value;

  /// Bagian yang sudah dimuat 0..1.
  final double buffered;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String semanticLabel;

  /// Teks posisi untuk pembaca layar, mis. "4 menit 15 detik".
  final String? semanticValue;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _drag;
  bool get _dragging => _drag != null;

  double _fraction(Offset local, double width) =>
      (local.dx / width).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final value = _drag ?? widget.value;
    final enabled = widget.onChanged != null;

    return Semantics(
      slider: true,
      enabled: enabled,
      label: widget.semanticLabel,
      value: widget.semanticValue ?? '${(widget.value * 100).round()}%',
      increasedValue: '${((widget.value + 0.05).clamp(0, 1) * 100).round()}%',
      decreasedValue: '${((widget.value - 0.05).clamp(0, 1) * 100).round()}%',
      onIncrease: enabled
          ? () => widget.onChangeEnd?.call((widget.value + 0.05).clamp(0, 1))
          : null,
      onDecrease: enabled
          ? () => widget.onChangeEnd?.call((widget.value - 0.05).clamp(0, 1))
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: enabled
                ? (d) {
                    final v = _fraction(d.localPosition, width);
                    widget.onChanged?.call(v);
                    widget.onChangeEnd?.call(v);
                  }
                : null,
            onHorizontalDragStart: enabled
                ? (d) => setState(() => _drag = _fraction(d.localPosition, width))
                : null,
            onHorizontalDragUpdate: enabled
                ? (d) {
                    final v = _fraction(d.localPosition, width);
                    setState(() => _drag = v);
                    widget.onChanged?.call(v);
                  }
                : null,
            onHorizontalDragEnd: enabled
                ? (_) {
                    final v = _drag ?? widget.value;
                    setState(() => _drag = null);
                    widget.onChangeEnd?.call(v);
                  }
                : null,
            child: SizedBox(
              height: 20,
              width: double.infinity,
              child: CustomPaint(
                painter: _SeekPainter(
                  value: value,
                  buffered: widget.buffered,
                  dragging: _dragging,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeekPainter extends CustomPainter {
  _SeekPainter({
    required this.value,
    required this.buffered,
    required this.dragging,
  });

  final double value;
  final double buffered;
  final bool dragging;

  static const double _trackHeight = 6;
  static const double _thumb = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final r = const Radius.circular(999);
    final track = RRect.fromLTRBR(
      0,
      cy - _trackHeight / 2,
      size.width,
      cy + _trackHeight / 2,
      r,
    );
    canvas.drawRRect(track, Paint()..color = AppColors.surface);

    canvas.save();
    canvas.clipRRect(track);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * buffered.clamp(0, 1), size.height),
      Paint()..color = AppColors.surfaceStrong,
    );
    final playedWidth = size.width * value.clamp(0, 1);
    if (playedWidth > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, playedWidth, size.height),
        Paint()
          ..shader = const LinearGradient(
            colors: [AppColors.surfaceStrong, AppColors.accent],
          ).createShader(Rect.fromLTWH(0, 0, playedWidth, size.height)),
      );
    }
    canvas.restore();

    // Pegangan: cahaya, cincin gelap, isi terang.
    final half = _thumb / 2;
    final x = (size.width * value.clamp(0, 1)).clamp(half, size.width - half);
    final center = Offset(x, cy);
    final scale = dragging ? 1.15 : 1.0;
    canvas.drawCircle(
      center,
      half * scale,
      Paint()
        ..color = AppColors.accentAt(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      center,
      (half + 2) * scale,
      Paint()..color = AppColors.background,
    );
    canvas.drawCircle(
      center,
      half * scale,
      Paint()..color = AppColors.accentLight,
    );
  }

  @override
  bool shouldRepaint(covariant _SeekPainter old) =>
      old.value != value || old.buffered != buffered || old.dragging != dragging;
}

/// Baris waktu di bawah bilah geser: sudah diputar, keterangan tengah, sisa.
class PlayerTimeline extends StatelessWidget {
  const PlayerTimeline({
    super.key,
    required this.elapsed,
    required this.remaining,
    this.centerLabel,
  });

  final String elapsed;
  final String remaining;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final time = AppTextStyles.custom(
      size: 12,
      lineHeight: 16,
      weight: FontWeight.w500,
      color: AppColors.textBody,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(elapsed, style: time),
        if (centerLabel != null)
          Text(
            centerLabel!.toUpperCase(),
            style: AppTextStyles.micro.copyWith(
              color: AppColors.accentLight,
              letterSpacing: 0.5,
            ),
          ),
        Text(remaining, style: time),
      ],
    );
  }
}
