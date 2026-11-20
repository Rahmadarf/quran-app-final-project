import 'package:flutter/widgets.dart';

/// Pembungkus sentuhan kustom: memberi umpan balik tekan (skala + redup)
/// dan semantik tombol. Dipakai semua komponen yang bisa diketuk.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.85,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Label untuk pembaca layar. Wajib untuk tombol yang hanya berisi ikon.
  final String? semanticLabel;
  final double pressedScale;
  final double pressedOpacity;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _pressed ? widget.pressedOpacity : 1,
        duration: const Duration(milliseconds: 90),
        child: widget.child,
      ),
    );

    return Semantics(
      button: _enabled,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: _enabled ? (_) => _set(true) : null,
        onTapUp: _enabled ? (_) => _set(false) : null,
        onTapCancel: _enabled ? () => _set(false) : null,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: content,
      ),
    );
  }
}
