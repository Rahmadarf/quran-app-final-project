import 'package:flutter/widgets.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/theme.dart';

/// Bilah geser pemutar dual-mode sesuai Figma `Obsidian / SeekBar`.
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

  final double value;
  final double buffered;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String semanticLabel;
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
    final palette = AppThemeScope.paletteOf(context);

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
                ? (d) =>
                    setState(() => _drag = _fraction(d.localPosition, width))
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
              height: 22,
              width: double.infinity,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _SeekPainter(
                    value: value,
                    buffered: widget.buffered,
                    dragging: _dragging,
                    palette: palette,
                  ),
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
    required this.palette,
  });

  final double value;
  final double buffered;
  final bool dragging;
  final AppThemePalette palette;

  static const double _trackHeight = 4;
  static const double _thumb = 13;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const r = Radius.circular(999);
    final track = RRect.fromLTRBR(
      0,
      cy - _trackHeight / 2,
      size.width,
      cy + _trackHeight / 2,
      r,
    );
    canvas.drawRRect(track, Paint()..color = palette.surfaceElevated);

    canvas.save();
    canvas.clipRRect(track);
    if (buffered > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * buffered.clamp(0, 1), size.height),
        Paint()..color = palette.borderStrong,
      );
    }
    final playedWidth = size.width * value.clamp(0, 1);
    if (playedWidth > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, playedWidth, size.height),
        Paint()..color = palette.accent,
      );
    }
    canvas.restore();

    final half = _thumb / 2;
    final x = (size.width * value.clamp(0, 1)).clamp(half, size.width - half);
    final center = Offset(x, cy);
    final scale = dragging ? 1.2 : 1.0;

    canvas.drawCircle(
      center,
      (half + 2) * scale,
      Paint()..color = palette.background,
    );
    canvas.drawCircle(
      center,
      half * scale,
      Paint()..color = palette.accent,
    );
  }

  @override
  bool shouldRepaint(covariant _SeekPainter old) =>
      old.value != value ||
      old.buffered != buffered ||
      old.dragging != dragging ||
      old.palette != palette;
}

/// Baris waktu di bawah bilah geser (tabular-nums).
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
    final palette = AppThemeScope.paletteOf(context);
    final time = AppTextStyles.caption.copyWith(color: palette.textMuted);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(elapsed, style: time),
        if (centerLabel != null)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                centerLabel!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.micro.copyWith(
                  color: palette.accentLight,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        Text(remaining, style: time),
      ],
    );
  }
}
