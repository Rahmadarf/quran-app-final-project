import '../../../core/errors/app_failure.dart';
import 'media_item.dart';

/// Fase mesin status pemutar (docs/05 §3.1).
enum PlayerPhase {
  idle,
  loading,
  playing,
  paused,
  buffering,
  completed,
  error,
}

/// Mode pengulangan pemutar (docs/05 §4).
enum RepeatMode {
  off,
  all,
  one;

  RepeatMode nextMode() {
    switch (this) {
      case RepeatMode.off:
        return RepeatMode.all;
      case RepeatMode.all:
        return RepeatMode.one;
      case RepeatMode.one:
        return RepeatMode.off;
    }
  }
}

/// Informasi kegagalan pemutaran yang aman ditampilkan ke pengguna.
class PlayerError {
  const PlayerError({
    required this.failure,
    this.canSkip = false,
  });

  final AppFailure failure;
  final bool canSkip;

  String get message => failure.userMessage;
}

/// Posisi dan buffer pemutaran yang dialirkan terpisah dari [PlayerState]
/// agar tidak membangun ulang seluruh pohon widget setiap 100 ms (docs/05 §3.2).
class PlaybackPosition {
  const PlaybackPosition({
    this.position = Duration.zero,
    this.buffered = Duration.zero,
    this.duration,
  });

  final Duration position;
  final Duration buffered;
  final Duration? duration;

  double get progress {
    final total = duration?.inMilliseconds ?? 0;
    if (total <= 0) return 0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  double get bufferedProgress {
    final total = duration?.inMilliseconds ?? 0;
    if (total <= 0) return 0;
    return (buffered.inMilliseconds / total).clamp(0.0, 1.0);
  }

  PlaybackPosition copyWith({
    Duration? position,
    Duration? buffered,
    Duration? duration,
  }) {
    return PlaybackPosition(
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      duration: duration ?? this.duration,
    );
  }
}

/// Status utama pemutar tunggal (docs/05 §3.2).
class PlayerState {
  const PlayerState({
    this.phase = PlayerPhase.idle,
    this.current,
    this.queue = const [],
    this.currentIndex = -1,
    this.repeat = RepeatMode.off,
    this.shuffle = false,
    this.speed = 1.0,
    this.error,
    this.sleepAt,
    this.sleepAtEndOfItem = false,
    this.queueSource,
    this.favoriteIds = const {},
  });

  final PlayerPhase phase;
  final MediaItem? current;
  final List<MediaItem> queue;
  final int currentIndex;
  final RepeatMode repeat;
  final bool shuffle;
  final double speed;
  final PlayerError? error;
  final DateTime? sleepAt;
  final bool sleepAtEndOfItem;
  final String? queueSource;
  final Set<String> favoriteIds;

  bool get isPlaying => phase == PlayerPhase.playing;
  bool get isLoadingOrBuffering =>
      phase == PlayerPhase.loading || phase == PlayerPhase.buffering;
  bool get hasActiveItem => current != null && phase != PlayerPhase.idle;
  bool get isCurrentFavorite =>
      current != null && favoriteIds.contains(current!.id);

  PlayerState copyWith({
    PlayerPhase? phase,
    MediaItem? current,
    bool clearCurrent = false,
    List<MediaItem>? queue,
    int? currentIndex,
    RepeatMode? repeat,
    bool? shuffle,
    double? speed,
    PlayerError? error,
    bool clearError = false,
    DateTime? sleepAt,
    bool clearSleepAt = false,
    bool? sleepAtEndOfItem,
    String? queueSource,
    bool clearQueueSource = false,
    Set<String>? favoriteIds,
  }) {
    return PlayerState(
      phase: phase ?? this.phase,
      current: clearCurrent ? null : (current ?? this.current),
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      repeat: repeat ?? this.repeat,
      shuffle: shuffle ?? this.shuffle,
      speed: speed ?? this.speed,
      error: clearError ? null : (error ?? this.error),
      sleepAt: clearSleepAt ? null : (sleepAt ?? this.sleepAt),
      sleepAtEndOfItem: sleepAtEndOfItem ?? this.sleepAtEndOfItem,
      queueSource: clearQueueSource ? null : (queueSource ?? this.queueSource),
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}
