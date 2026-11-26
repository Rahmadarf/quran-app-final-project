import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/player_state.dart';
import 'player_controller.dart';

/// Menyediakan [PlayerController] ke seluruh pohon widget (docs/05 §1).
class PlayerScope extends InheritedNotifier<PlayerController> {
  const PlayerScope({
    super.key,
    required PlayerController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlayerController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlayerScope>();
    assert(scope != null, 'PlayerScope tidak ditemukan di atas widget ini');
    return scope!.notifier!;
  }

  /// Membaca [PlayerController] tanpa mendaftarkan rebuild widget pemanggil.
  static PlayerController read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<PlayerScope>();
    final scope = element?.widget as PlayerScope?;
    assert(scope != null, 'PlayerScope tidak ditemukan di atas widget ini');
    return scope!.notifier!;
  }
}

/// Widget kecil yang hanya membangun ulang ketika posisi/buffer berubah
/// (~10 Hz) agar layar utama dan pemutar tetap 60 fps (docs/05 §8).
class PlaybackPositionBuilder extends StatelessWidget {
  const PlaybackPositionBuilder({
    super.key,
    required this.positionListenable,
    required this.builder,
  });

  final ValueListenable<PlaybackPosition> positionListenable;
  final Widget Function(BuildContext context, PlaybackPosition pos) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaybackPosition>(
      valueListenable: positionListenable,
      builder: (context, pos, _) => builder(context, pos),
    );
  }
}
