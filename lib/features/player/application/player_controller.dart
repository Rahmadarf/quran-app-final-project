import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/network/failure_mapper.dart';
import '../../quran/data/quran_repository_impl.dart';
import '../../quran/domain/quran_repository.dart';
import '../../quran/domain/surah.dart';
import '../data/audio_engine.dart';
import '../domain/media_item.dart';
import '../domain/play_queue.dart';
import '../domain/player_state.dart';
import 'audio_source_resolver.dart';

export 'player_providers.dart';

/// Pengendali pemutar audio tunggal di luar pohon widget (docs/05 §3–§5).
class PlayerController extends ChangeNotifier {
  PlayerController({
    AudioEngine? engine,
    QuranRepository? quranRepository,
    AudioSourceResolver? sourceResolver,
  })  : _engine = engine ?? createDefaultAudioEngine(),
        _quranRepository = quranRepository ?? QuranRepositoryImpl(),
        _sourceResolver = sourceResolver ?? const AudioSourceResolver() {
    _phaseSub = _engine.phaseStream.listen(_onEnginePhase);
    _positionSub = _engine.positionStream.listen(_onEnginePosition);
  }

  static const String _prefsKey = 'player_state_v1';
  static const Duration _bufferingTimeout = Duration(seconds: 20);
  static const Duration _positionThrottle = Duration(milliseconds: 100);

  final AudioEngine _engine;
  final QuranRepository _quranRepository;
  final AudioSourceResolver _sourceResolver;
  final PlayQueue _queue = PlayQueue();

  final ValueNotifier<PlaybackPosition> _positionNotifier =
      ValueNotifier<PlaybackPosition>(const PlaybackPosition());

  PlayerState _state = const PlayerState();
  String _selectedQariId = AppConstants.defaultQariId;
  List<Surah> _cachedSurahs = const [];
  String? _statusNotice;

  StreamSubscription<PlayerPhase>? _phaseSub;
  StreamSubscription<PlaybackPosition>? _positionSub;
  Timer? _bufferingTimer;
  Timer? _sleepTimer;
  Timer? _fadeTimer;
  DateTime? _lastPositionEmit;
  bool _disposed = false;
  bool _suppressAutoAdvance = false;

  PlayerState get state => _state;
  ValueListenable<PlaybackPosition> get positionListenable => _positionNotifier;
  PlaybackPosition get position => _positionNotifier.value;
  String get selectedQariId => _selectedQariId;
  List<Surah> get cachedSurahs => _cachedSurahs;
  String? get statusNotice => _statusNotice;

  // Getter kompatibel untuk widget yang sudah ada.
  bool get playing => _state.isPlaying;
  bool get favorite => _state.isCurrentFavorite;
  bool get shuffle => _state.shuffle;
  bool get repeatOne => _state.repeat == RepeatMode.one;
  double get progress => _positionNotifier.value.progress;
  int get totalSeconds => _positionNotifier.value.duration?.inSeconds ?? 0;
  int get elapsedSeconds => _positionNotifier.value.position.inSeconds;
  int get remainingSeconds {
    final total = _positionNotifier.value.duration;
    if (total == null) return 0;
    final rem = total - _positionNotifier.value.position;
    return rem.isNegative ? 0 : rem.inSeconds;
  }

  void clearStatusNotice() {
    if (_statusNotice == null) return;
    _statusNotice = null;
    _safeNotify();
  }

  /// Memulihkan item aktif, antrean, dan preferensi terakhir dalam keadaan jeda
  /// (docs/05 §5). Tidak pernah memutar otomatis saat startup.
  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;

      final speed = (json['speed'] as num?)?.toDouble() ?? 1.0;
      final repeatName = json['repeat'] as String?;
      final repeat = RepeatMode.values.firstWhere(
        (m) => m.name == repeatName,
        orElse: () => RepeatMode.off,
      );
      final qariId = json['qariId'] as String? ?? AppConstants.defaultQariId;
      final favs = (json['favoriteIds'] as List?)
              ?.whereType<String>()
              .toSet() ??
          const <String>{};
      final rawQueue = (json['queue'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(MediaItem.fromJson)
              .toList() ??
          const <MediaItem>[];
      final currentIndex = (json['currentIndex'] as num?)?.toInt() ?? 0;
      final positionMs = (json['positionMs'] as num?)?.toInt() ?? 0;
      final queueSource = json['queueSource'] as String?;

      _selectedQariId = qariId;
      await _engine.setSpeed(speed);

      if (rawQueue.isNotEmpty) {
        _queue.setItems(
          rawQueue,
          startIndex: currentIndex.clamp(0, rawQueue.length - 1),
          source: queueSource,
        );
        final item = _queue.current;
        _state = _state.copyWith(
          phase: PlayerPhase.paused,
          current: item,
          queue: _queue.items,
          currentIndex: _queue.currentIndex,
          repeat: repeat,
          speed: speed,
          favoriteIds: favs,
          queueSource: queueSource,
        );
        _positionNotifier.value = PlaybackPosition(
          position: Duration(milliseconds: positionMs),
          duration: item?.duration,
        );
      } else {
        _state = _state.copyWith(
          repeat: repeat,
          speed: speed,
          favoriteIds: favs,
        );
      }
      _safeNotify();
    } catch (_) {
      // Abaikan state korup agar aplikasi tetap bisa dimulai.
    }
  }

  /// Memuat daftar 114 surat dari API/cache untuk pemilih surat dan antrean.
  Future<List<Surah>> loadSurahs() async {
    if (_cachedSurahs.isNotEmpty) return _cachedSurahs;
    final list = await _quranRepository.getSurahs();
    _cachedSurahs = list;
    return list;
  }

  /// Memutar surat dari API equran.id berdasarkan [surahNumber] dan [qariId]
  /// (docs/02 §4.1, 05 §2).
  Future<void> playSurah(
    int surahNumber, {
    String? qariId,
    String? qariName,
    String? queueSource,
  }) async {
    final targetQari = qariId ?? _selectedQariId;
    _selectedQariId = targetQari;

    // Jika item yang sama sedang aktif, cukup lanjutkan jika dijeda.
    final expectedId = 'surah:$surahNumber:$targetQari';
    if (_state.current?.id == expectedId &&
        _state.phase != PlayerPhase.error &&
        _state.phase != PlayerPhase.idle) {
      if (!_state.isPlaying) {
        await resume();
      }
      return;
    }

    _state = _state.copyWith(
      phase: PlayerPhase.loading,
      clearError: true,
    );
    _safeNotify();

    try {
      final surahs = await loadSurahs();
      final detail = await _quranRepository.getSurahDetail(surahNumber);
      final uri = detail.fullAudioForQari(targetQari);
      if (uri == null) {
        throw const AppFailure(
          AppFailureKind.notFound,
          message: 'Audio untuk qari ini belum tersedia pada surat tersebut.',
        );
      }

      final displayQari = qariName ?? _qariDisplayName(targetQari);
      final item = _surahToMediaItem(detail, targetQari, displayQari, uri);

      // Bentuk antrean surat dari surat ini hingga surat 114 (docs/05 §5).
      final startIdx =
          surahs.indexWhere((s) => s.number == surahNumber).clamp(0, surahs.length);
      final queueItems = <MediaItem>[];
      for (var i = 0; i < surahs.length; i++) {
        final s = surahs[i];
        final sUri = s.fullAudioForQari(targetQari);
        if (sUri == null) continue;
        queueItems.add(
          s.number == surahNumber
              ? item
              : _surahToMediaItem(s, targetQari, displayQari, sUri),
        );
      }

      final activeInQueue =
          queueItems.indexWhere((e) => e.id == item.id);
      await playItem(
        item,
        queue: queueItems.isEmpty ? [item] : queueItems,
        startIndex: activeInQueue >= 0 ? activeInQueue : startIdx,
        queueSource: queueSource ?? 'Daftar Surat · $displayQari',
      );
    } catch (e) {
      final failure = mapToAppFailure(e);
      _state = _state.copyWith(
        phase: PlayerPhase.error,
        error: PlayerError(failure: failure, canSkip: _queue.length > 1),
      );
      _safeNotify();
    }
  }

  /// Memutar satu [MediaItem] beserta [queue] opsional (docs/05 §4).
  Future<void> playItem(
    MediaItem item, {
    List<MediaItem>? queue,
    int startIndex = 0,
    String? queueSource,
  }) async {
    // Mengetuk item yang sama yang sedang aktif tidak mengulang dari awal.
    if (_state.current?.id == item.id &&
        _state.phase != PlayerPhase.idle &&
        _state.phase != PlayerPhase.error &&
        queue == null) {
      if (!_state.isPlaying) {
        await resume();
      }
      return;
    }

    if (queue != null && queue.isNotEmpty) {
      final idx = startIndex >= 0 && startIndex < queue.length
          ? startIndex
          : queue.indexOf(item).clamp(0, queue.length - 1);
      final truncated = _queue.setItems(
        queue,
        startIndex: idx,
        shuffle: _state.shuffle,
        source: queueSource,
      );
      if (truncated) {
        _statusNotice =
            'Antrean dibatasi maksimal ${AppConstants.maxQueueLength} item.';
      }
    } else if (_queue.isEmpty) {
      _queue.setItems([item], source: queueSource);
    } else {
      final existingIdx = _queue.items.indexOf(item);
      if (existingIdx >= 0) {
        _queue.jumpTo(existingIdx);
      } else {
        _queue.setItems([item], source: queueSource);
      }
    }

    await _loadAndPlayCurrent();
  }

  Future<void> _loadAndPlayCurrent({bool autoplay = true}) async {
    final item = _queue.current;
    if (item == null) {
      await stop();
      return;
    }

    _bufferingTimer?.cancel();
    _suppressAutoAdvance = true;
    _state = _state.copyWith(
      phase: PlayerPhase.loading,
      current: item,
      queue: _queue.items,
      currentIndex: _queue.currentIndex,
      queueSource: _queue.source,
      clearError: true,
    );
    _positionNotifier.value = PlaybackPosition(duration: item.duration);
    _safeNotify();

    try {
      final resolved = await _sourceResolver.resolve(item);
      final loadedDuration = await _engine.load(
        item,
        resolved.uri,
        isAsset: resolved.isAsset,
      );

      if (loadedDuration != null && loadedDuration != item.duration) {
        final updated = item.copyWith(duration: loadedDuration);
        _state = _state.copyWith(current: updated);
        _positionNotifier.value =
            _positionNotifier.value.copyWith(duration: loadedDuration);
      }

      await _engine.setSpeed(_state.speed);
      await _engine.setVolume(1.0);
      _suppressAutoAdvance = false;

      if (autoplay) {
        await _engine.play();
      } else {
        _state = _state.copyWith(phase: PlayerPhase.paused);
        _safeNotify();
      }
      unawaited(_persist());
    } catch (e) {
      _suppressAutoAdvance = false;
      final failure = mapToAppFailure(e);
      _state = _state.copyWith(
        phase: PlayerPhase.error,
        error: PlayerError(failure: failure, canSkip: _queue.length > 1),
      );
      _safeNotify();
    }
  }

  Future<void> play() => resume();

  Future<void> resume() async {
    if (_state.current == null) return;
    if (_state.phase == PlayerPhase.error) {
      await retry();
      return;
    }
    if (_state.phase == PlayerPhase.paused ||
        _state.phase == PlayerPhase.completed) {
      if (_state.phase == PlayerPhase.completed) {
        await _engine.seek(Duration.zero);
      }
      await _engine.play();
    }
  }

  Future<void> pause() async {
    if (_state.phase == PlayerPhase.playing ||
        _state.phase == PlayerPhase.buffering) {
      await _engine.pause();
      unawaited(_persist());
    }
  }

  Future<void> togglePlay() async {
    if (_state.current == null) {
      // Bawaan: mulai memutar Ar-Rahman (surat 55) bila belum ada item aktif.
      await playSurah(55, qariId: _selectedQariId);
      return;
    }
    if (_state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> retry() async {
    if (_state.current == null) return;
    await _loadAndPlayCurrent();
  }

  Future<void> seek(double fraction) async {
    final total = _positionNotifier.value.duration;
    if (total == null || total.inMilliseconds <= 0) return;
    final targetMs = (fraction.clamp(0.0, 1.0) * total.inMilliseconds).round();
    await seekTo(Duration(milliseconds: targetMs));
  }

  Future<void> seekTo(Duration target) async {
    final total = _positionNotifier.value.duration;
    final maxMs = total?.inMilliseconds ?? target.inMilliseconds;
    final clamped = Duration(
      milliseconds: target.inMilliseconds.clamp(0, maxMs < 0 ? 0 : maxMs),
    );
    _positionNotifier.value =
        _positionNotifier.value.copyWith(position: clamped);
    await _engine.seek(clamped);
  }

  Future<void> skip(Duration delta) async {
    final current = _state.current;
    if (current == null || !current.kind.supportsSkip15s) return;
    await seekTo(_positionNotifier.value.position + delta);
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_state.repeat == RepeatMode.one) {
      await seekTo(Duration.zero);
      await resume();
      return;
    }
    final nextIdx = _queue.nextIndex(_state.repeat);
    if (nextIdx == null) {
      await pause();
      _state = _state.copyWith(phase: PlayerPhase.completed);
      _safeNotify();
      return;
    }
    _queue.jumpTo(nextIdx);
    await _loadAndPlayCurrent();
  }

  /// Bila posisi > 3 detik: kembali ke awal item; bila <= 3 detik: item
  /// sebelumnya (docs/05 §4).
  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_positionNotifier.value.position > const Duration(seconds: 3)) {
      await seekTo(Duration.zero);
      return;
    }
    final prevIdx = _queue.previousIndex(_state.repeat);
    if (prevIdx == null) {
      await seekTo(Duration.zero);
      return;
    }
    _queue.jumpTo(prevIdx);
    await _loadAndPlayCurrent();
  }

  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 2.0);
    _state = _state.copyWith(speed: clamped);
    await _engine.setSpeed(clamped);
    _safeNotify();
    unawaited(_persist());
  }

  void toggleShuffle() => setShuffle(!_state.shuffle);

  void setShuffle(bool enabled) {
    _queue.setShuffle(enabled);
    _state = _state.copyWith(
      shuffle: enabled,
      queue: _queue.items,
      currentIndex: _queue.currentIndex,
    );
    _safeNotify();
    unawaited(_persist());
  }

  void cycleRepeat() => setRepeat(_state.repeat.nextMode());

  void toggleRepeatOne() {
    setRepeat(
      _state.repeat == RepeatMode.one ? RepeatMode.off : RepeatMode.one,
    );
  }

  void setRepeat(RepeatMode mode) {
    _state = _state.copyWith(repeat: mode);
    _safeNotify();
    unawaited(_persist());
  }

  /// Timer tidur dengan pemudaran volume 5 detik sebelum berhenti (docs/05 §4).
  void setSleepTimer(Duration? duration, {bool endOfItem = false}) {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    unawaited(_engine.setVolume(1.0));

    if (duration == null && !endOfItem) {
      _state = _state.copyWith(clearSleepAt: true, sleepAtEndOfItem: false);
      _safeNotify();
      return;
    }

    if (endOfItem) {
      _state = _state.copyWith(clearSleepAt: true, sleepAtEndOfItem: true);
      _safeNotify();
      return;
    }

    final target = DateTime.now().add(duration!);
    _state = _state.copyWith(sleepAt: target, sleepAtEndOfItem: false);
    _safeNotify();

    const fadeDuration = Duration(seconds: 5);
    if (duration > fadeDuration) {
      _sleepTimer = Timer(duration - fadeDuration, _startSleepFadeOut);
    } else {
      _startSleepFadeOut();
    }
  }

  void _startSleepFadeOut() {
    var step = 0;
    const steps = 10;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      step++;
      final volume = (1.0 - step / steps).clamp(0.0, 1.0);
      await _engine.setVolume(volume);
      if (step >= steps) {
        timer.cancel();
        await pause();
        await _engine.setVolume(1.0);
        _state = _state.copyWith(clearSleepAt: true, sleepAtEndOfItem: false);
        _safeNotify();
      }
    });
  }

  void enqueue(MediaItem item) {
    final ok = _queue.enqueue(item);
    if (!ok) {
      _statusNotice =
          'Antrean penuh (maksimal ${AppConstants.maxQueueLength} item).';
    }
    _state = _state.copyWith(
      queue: _queue.items,
      currentIndex: _queue.currentIndex,
    );
    _safeNotify();
    unawaited(_persist());
  }

  void playNext(MediaItem item) {
    final ok = _queue.playNext(item);
    if (!ok) {
      _statusNotice =
          'Antrean penuh (maksimal ${AppConstants.maxQueueLength} item).';
    }
    _state = _state.copyWith(
      queue: _queue.items,
      currentIndex: _queue.currentIndex,
    );
    _safeNotify();
    unawaited(_persist());
  }

  Future<void> removeFromQueue(int index) async {
    final removedWasCurrent = index == _queue.currentIndex;
    _queue.removeAt(index);
    if (_queue.isEmpty) {
      await stop();
      return;
    }
    _state = _state.copyWith(
      queue: _queue.items,
      currentIndex: _queue.currentIndex,
    );
    if (removedWasCurrent) {
      await _loadAndPlayCurrent(autoplay: _state.isPlaying);
    } else {
      _safeNotify();
      unawaited(_persist());
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _queue.reorder(oldIndex, newIndex);
    _state = _state.copyWith(
      queue: _queue.items,
      currentIndex: _queue.currentIndex,
    );
    _safeNotify();
    unawaited(_persist());
  }

  Future<void> jumpToQueueIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _queue.jumpTo(index);
    await _loadAndPlayCurrent();
  }

  void toggleFavorite() {
    final id = _state.current?.id;
    if (id == null) return;
    final next = Set<String>.of(_state.favoriteIds);
    if (!next.remove(id)) {
      next.add(id);
    }
    _state = _state.copyWith(favoriteIds: next);
    _safeNotify();
    unawaited(_persist());
  }

  Future<void> stop() async {
    _bufferingTimer?.cancel();
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _suppressAutoAdvance = true;
    await _engine.stop();
    _suppressAutoAdvance = false;
    _queue.clear();
    _state = _state.copyWith(
      phase: PlayerPhase.idle,
      clearCurrent: true,
      queue: const [],
      currentIndex: -1,
      clearError: true,
      clearSleepAt: true,
      sleepAtEndOfItem: false,
      clearQueueSource: true,
    );
    _positionNotifier.value = const PlaybackPosition();
    _safeNotify();
    unawaited(_persist());
  }

  void _onEnginePhase(PlayerPhase phase) {
    if (_disposed) return;

    if (phase == PlayerPhase.buffering) {
      _bufferingTimer?.cancel();
      _bufferingTimer = Timer(_bufferingTimeout, () {
        if (_state.phase == PlayerPhase.buffering) {
          _state = _state.copyWith(
            phase: PlayerPhase.error,
            error: PlayerError(
              failure: const AppFailure(AppFailureKind.timeout),
              canSkip: _queue.length > 1,
            ),
          );
          _safeNotify();
        }
      });
    } else {
      _bufferingTimer?.cancel();
    }

    if (phase == PlayerPhase.completed && !_suppressAutoAdvance) {
      if (_state.sleepAtEndOfItem) {
        _state = _state.copyWith(
          phase: PlayerPhase.paused,
          sleepAtEndOfItem: false,
        );
        _safeNotify();
        return;
      }
      if (_state.repeat == RepeatMode.one) {
        unawaited(seekTo(Duration.zero).then((_) => _engine.play()));
        return;
      }
      final nextIdx = _queue.nextIndex(_state.repeat);
      if (nextIdx != null) {
        _queue.jumpTo(nextIdx);
        unawaited(_loadAndPlayCurrent());
        return;
      }
    }

    if (_state.phase != phase) {
      _state = _state.copyWith(phase: phase);
      _safeNotify();
    }
  }

  void _onEnginePosition(PlaybackPosition pos) {
    if (_disposed) return;
    final now = DateTime.now();
    // Batasi pembaruan UI menjadi ~10 Hz (100 ms) sesuai docs/05 §8.
    if (_lastPositionEmit != null &&
        now.difference(_lastPositionEmit!) < _positionThrottle &&
        pos.position != Duration.zero &&
        pos.position != pos.duration) {
      return;
    }
    _lastPositionEmit = now;
    _positionNotifier.value = pos;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'speed': _state.speed,
        'repeat': _state.repeat.name,
        'qariId': _selectedQariId,
        'favoriteIds': _state.favoriteIds.toList(),
        'queue': _state.queue.map((e) => e.toJson()).toList(),
        'currentIndex': _state.currentIndex,
        'positionMs': _positionNotifier.value.position.inMilliseconds,
        if (_state.queueSource != null) 'queueSource': _state.queueSource,
      };
      await prefs.setString(_prefsKey, jsonEncode(payload));
    } catch (_) {
      // Abaikan bila penyimpanan tidak tersedia (mis. test).
    }
  }

  String _qariDisplayName(String qariId) {
    const names = {
      '01': 'Abdullah Al-Juhany',
      '02': 'Abdul Muhsin Al-Qasim',
      '03': 'Abdurrahman As-Sudais',
      '04': 'Ibrahim Al-Dossari',
      '05': 'Misyari Rasyid Al-Afasi',
      '06': 'Yasser Al-Dosari',
    };
    return names[qariId] ?? 'Qari $qariId';
  }

  MediaItem _surahToMediaItem(
    Surah surah,
    String qariId,
    String qariName,
    Uri audioUri,
  ) {
    return MediaItem(
      id: 'surah:${surah.number}:$qariId',
      kind: MediaKind.surah,
      source: MediaSource.api,
      title: 'Surat ${surah.latinName}',
      subtitle: qariName,
      audioUri: audioUri,
      artwork: _artworkForSurah(surah.number),
      meta: {
        'surahNumber': surah.number,
        'surahLatinName': surah.latinName,
        'surahArabicName': surah.arabicName,
        'ayahCount': surah.ayahCount,
        'qariId': qariId,
      },
    );
  }

  String? _artworkForSurah(int surahNumber) {
    switch (surahNumber) {
      case 18:
        return 'assets/images/covers/al-kahfi.png';
      case 36:
        return 'assets/images/covers/yasin.png';
      case 55:
        return 'assets/images/covers/ar-rahman.png';
      default:
        return null;
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _bufferingTimer?.cancel();
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _phaseSub?.cancel();
    _positionSub?.cancel();
    _positionNotifier.dispose();
    unawaited(_engine.dispose());
    super.dispose();
  }
}

/// "04:15" untuk detik tertentu.
String formatClock(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
