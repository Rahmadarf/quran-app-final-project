import 'dart:async';

import 'package:flutter/widgets.dart';

/// Pengendali pemutar tunggal yang berada di luar pohon widget (docs/05 §4).
///
/// CATATAN: ini versi demo untuk menghidupkan antarmuka. Belum ada mesin
/// audio (`just_audio`); "putar" hanya menggerakkan posisi simulasi 1 detik
/// per detik. Antarmuka publiknya sengaja kecil supaya bisa diganti dengan
/// implementasi nyata tanpa mengubah layar.
class PlayerController extends ChangeNotifier {
  PlayerController({
    this.totalSeconds = 990,
    double initialProgress = 255 / 990,
  }) : _progress = initialProgress;

  /// Durasi item saat ini dalam detik (contoh: 16:30).
  final int totalSeconds;

  double _progress;
  bool _playing = false;
  bool _favorite = true;
  bool _shuffle = false;
  bool _repeatOne = true;
  Timer? _ticker;

  bool get playing => _playing;
  bool get favorite => _favorite;
  bool get shuffle => _shuffle;
  bool get repeatOne => _repeatOne;

  /// Posisi 0..1.
  double get progress => _progress;
  int get elapsedSeconds => (_progress * totalSeconds).round();
  int get remainingSeconds => totalSeconds - elapsedSeconds;

  void togglePlay() {
    _playing = !_playing;
    _ticker?.cancel();
    if (_playing) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        _progress = (_progress + 1 / totalSeconds).clamp(0.0, 1.0);
        if (_progress >= 1) {
          _playing = false;
          _ticker?.cancel();
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void play() {
    if (!_playing) togglePlay();
  }

  void seek(double value) {
    _progress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleFavorite() {
    _favorite = !_favorite;
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeatOne() {
    _repeatOne = !_repeatOne;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// Menyediakan [PlayerController] ke seluruh pohon widget. Layar yang
/// membaca status ikut dibangun ulang saat controller berubah.
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
}

/// "04:15" untuk detik tertentu.
String formatClock(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
