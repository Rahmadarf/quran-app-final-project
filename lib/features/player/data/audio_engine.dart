import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart' hide RepeatMode;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_background/just_audio_background.dart' as jab;

import '../../../core/errors/app_failure.dart';
import '../domain/media_item.dart';
import '../domain/player_state.dart';

/// Satu entri sumber audio dalam daftar putar native [AudioEngine].
class PlaylistEntry {
  const PlaylistEntry({
    required this.item,
    required this.resolvedUri,
    required this.isAsset,
  });

  final MediaItem item;
  final Uri resolvedUri;
  final bool isAsset;
}

/// Kontrak mesin audio agar [PlayerController] dapat diuji tanpa platform channel.
abstract interface class AudioEngine {
  Stream<PlayerPhase> get phaseStream;
  Stream<PlaybackPosition> get positionStream;

  /// Memancarkan indeks item aktif saat mesin audio berpindah trek dalam
  /// daftar putar native (mis. perpindahan otomatis antarayat).
  Stream<int?> get currentIndexStream;

  Future<Duration?> load(
    MediaItem item,
    Uri resolvedUri, {
    required bool isAsset,
  });

  /// Memuat seluruh daftar putar ke mesin audio sekaligus agar trek berikutnya
  /// otomatis di-prebuffer (perpindahan antarayat halus).
  Future<Duration?> loadPlaylist(
    List<PlaylistEntry> entries, {
    int initialIndex = 0,
  });

  /// Melompat instan ke indeks tertentu dalam daftar putar native aktif.
  Future<void> seekToIndex(int index, {Duration position = Duration.zero});

  Future<void> setLoopMode(RepeatMode mode);

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> setVolume(double volume);
  Future<void> dispose();
}

/// Implementasi nyata [AudioEngine] berbasis `just_audio` dan `audio_session`
/// serta metadata layar kunci lewat `just_audio_background` (docs/05 §6).
class JustAudioEngine implements AudioEngine {
  JustAudioEngine({ja.AudioPlayer? player})
      : _player = player ?? ja.AudioPlayer() {
    _initSession();
    _playerSub = _player.playerStateStream.listen(_handlePlayerState);
    _positionSub = _player.positionStream.listen((pos) {
      _lastPosition = pos;
      _emitPosition();
    });
    _bufferedSub = _player.bufferedPositionStream.listen((buf) {
      _lastBuffered = buf;
      _emitPosition();
    });
    _durationSub = _player.durationStream.listen((dur) {
      _lastDuration = dur;
      _emitPosition();
    });
    _indexSub = _player.currentIndexStream.listen((idx) {
      if (!_indexController.isClosed) {
        _indexController.add(idx);
      }
    });
  }

  final ja.AudioPlayer _player;
  final StreamController<PlayerPhase> _phaseController =
      StreamController<PlayerPhase>.broadcast();
  final StreamController<PlaybackPosition> _positionController =
      StreamController<PlaybackPosition>.broadcast();
  final StreamController<int?> _indexController =
      StreamController<int?>.broadcast();

  StreamSubscription<ja.PlayerState>? _playerSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _bufferedSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _noisySub;

  Duration _lastPosition = Duration.zero;
  Duration _lastBuffered = Duration.zero;
  Duration? _lastDuration;
  bool _wasPlayingBeforeInterruption = false;

  @override
  Stream<PlayerPhase> get phaseStream => _phaseController.stream;

  @override
  Stream<PlaybackPosition> get positionStream => _positionController.stream;

  @override
  Stream<int?> get currentIndexStream => _indexController.stream;

  Future<void> _initSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _interruptionSub = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          _wasPlayingBeforeInterruption = _player.playing;
          if (_player.playing) {
            _player.pause();
          }
        } else if (event.type == AudioInterruptionType.pause &&
            _wasPlayingBeforeInterruption) {
          _wasPlayingBeforeInterruption = false;
          _player.play();
        }
      });
      _noisySub = session.becomingNoisyEventStream.listen((_) {
        if (_player.playing) {
          _player.pause();
        }
      });
    } catch (_) {
      // Abaikan bila AudioSession tidak tersedia di platform tertentu (mis. test).
    }
  }

  void _handlePlayerState(ja.PlayerState state) {
    if (_phaseController.isClosed) return;
    switch (state.processingState) {
      case ja.ProcessingState.idle:
        _phaseController.add(PlayerPhase.idle);
      case ja.ProcessingState.loading:
        _phaseController.add(PlayerPhase.loading);
      case ja.ProcessingState.buffering:
        _phaseController.add(PlayerPhase.buffering);
      case ja.ProcessingState.ready:
        _phaseController
            .add(state.playing ? PlayerPhase.playing : PlayerPhase.paused);
      case ja.ProcessingState.completed:
        _phaseController.add(PlayerPhase.completed);
    }
  }

  void _emitPosition() {
    if (_positionController.isClosed) return;
    _positionController.add(
      PlaybackPosition(
        position: _lastPosition,
        buffered: _lastBuffered,
        duration: _lastDuration,
      ),
    );
  }

  ja.AudioSource _buildSource(
    MediaItem item,
    Uri resolvedUri, {
    required bool isAsset,
  }) {
    final tag = jab.MediaItem(
      id: item.id,
      title: item.title,
      artist: item.subtitle,
      album: item.kind.hasReader ? "Al-Qur'an" : 'Quran Audio',
    );
    return isAsset
        ? ja.AudioSource.asset(
            resolvedUri.path.isNotEmpty
                ? resolvedUri.path.replaceFirst(RegExp(r'^/'), '')
                : resolvedUri.toString().replaceFirst('asset://', ''),
            tag: tag,
          )
        : ja.AudioSource.uri(resolvedUri, tag: tag);
  }

  @override
  Future<Duration?> load(
    MediaItem item,
    Uri resolvedUri, {
    required bool isAsset,
  }) async {
    try {
      final source = _buildSource(item, resolvedUri, isAsset: isAsset);
      final duration = await _player.setAudioSource(source);
      _lastPosition = Duration.zero;
      _lastBuffered = Duration.zero;
      _lastDuration = duration;
      _emitPosition();
      return duration;
    } on ja.PlayerException catch (e) {
      throw AppFailure(
        AppFailureKind.unknown,
        message: 'Gagal memuat audio (${e.message ?? 'tidak tersedia'}).',
        cause: e,
      );
    } catch (e) {
      throw AppFailure(AppFailureKind.unknown, cause: e);
    }
  }

  @override
  Future<Duration?> loadPlaylist(
    List<PlaylistEntry> entries, {
    int initialIndex = 0,
  }) async {
    if (entries.isEmpty) return null;
    try {
      final safeIdx = initialIndex.clamp(0, entries.length - 1);
      final sources = [
        for (final e in entries)
          _buildSource(e.item, e.resolvedUri, isAsset: e.isAsset),
      ];
      final duration = await _player.setAudioSources(
        sources,
        initialIndex: safeIdx,
        initialPosition: Duration.zero,
      );
      _lastPosition = Duration.zero;
      _lastBuffered = Duration.zero;
      _lastDuration = duration;
      _emitPosition();
      return duration;
    } on ja.PlayerException catch (e) {
      throw AppFailure(
        AppFailureKind.unknown,
        message: 'Gagal memuat audio (${e.message ?? 'tidak tersedia'}).',
        cause: e,
      );
    } catch (e) {
      throw AppFailure(AppFailureKind.unknown, cause: e);
    }
  }

  @override
  Future<void> seekToIndex(
    int index, {
    Duration position = Duration.zero,
  }) async {
    await _player.seek(position, index: index);
  }

  @override
  Future<void> setLoopMode(RepeatMode mode) async {
    final jaMode = switch (mode) {
      RepeatMode.off => ja.LoopMode.off,
      RepeatMode.all => ja.LoopMode.all,
      RepeatMode.one => ja.LoopMode.one,
    };
    await _player.setLoopMode(jaMode);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0.0, 1.0));

  @override
  Future<void> dispose() async {
    await _playerSub?.cancel();
    await _positionSub?.cancel();
    await _bufferedSub?.cancel();
    await _durationSub?.cancel();
    await _indexSub?.cancel();
    await _interruptionSub?.cancel();
    await _noisySub?.cancel();
    await _phaseController.close();
    await _positionController.close();
    await _indexController.close();
    await _player.dispose();
  }
}

/// Mesin audio simulasi untuk lingkungan pengujian widget/unit tanpa plugin native.
class SimulatedAudioEngine implements AudioEngine {
  SimulatedAudioEngine({this._defaultDuration = const Duration(minutes: 4)});

  final Duration _defaultDuration;
  final StreamController<PlayerPhase> _phaseController =
      StreamController<PlayerPhase>.broadcast();
  final StreamController<PlaybackPosition> _positionController =
      StreamController<PlaybackPosition>.broadcast();
  final StreamController<int?> _indexController =
      StreamController<int?>.broadcast();

  Timer? _ticker;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  bool _playing = false;

  List<Duration> _playlistDurations = const [];
  int _currentIndex = 0;
  RepeatMode _loopMode = RepeatMode.off;

  @override
  Stream<PlayerPhase> get phaseStream => _phaseController.stream;

  @override
  Stream<PlaybackPosition> get positionStream => _positionController.stream;

  @override
  Stream<int?> get currentIndexStream => _indexController.stream;

  @override
  Future<Duration?> load(
    MediaItem item,
    Uri resolvedUri, {
    required bool isAsset,
  }) async {
    _ticker?.cancel();
    _playing = false;
    _position = Duration.zero;
    _duration = item.duration ?? _defaultDuration;
    _playlistDurations = [_duration];
    _currentIndex = 0;
    _phaseController.add(PlayerPhase.paused);
    _emit();
    return _duration;
  }

  @override
  Future<Duration?> loadPlaylist(
    List<PlaylistEntry> entries, {
    int initialIndex = 0,
  }) async {
    _ticker?.cancel();
    _playing = false;
    if (entries.isEmpty) return null;
    _playlistDurations = [
      for (final e in entries) e.item.duration ?? _defaultDuration,
    ];
    _currentIndex = initialIndex.clamp(0, entries.length - 1);
    _position = Duration.zero;
    _duration = _playlistDurations[_currentIndex];
    _phaseController.add(PlayerPhase.paused);
    if (!_indexController.isClosed) {
      _indexController.add(_currentIndex);
    }
    _emit();
    return _duration;
  }

  @override
  Future<void> seekToIndex(
    int index, {
    Duration position = Duration.zero,
  }) async {
    if (_playlistDurations.isEmpty) return;
    _currentIndex = index.clamp(0, _playlistDurations.length - 1);
    _duration = _playlistDurations[_currentIndex];
    final maxMs = _duration.inMilliseconds;
    _position = Duration(
      milliseconds: position.inMilliseconds.clamp(0, maxMs < 0 ? 0 : maxMs),
    );
    if (!_indexController.isClosed) {
      _indexController.add(_currentIndex);
    }
    _emit();
  }

  @override
  Future<void> setLoopMode(RepeatMode mode) async {
    _loopMode = mode;
  }

  /// Menstimulasikan selesainya trek saat ini (berguna untuk pengujian transisi
  /// otomatis antarayat di daftar putar native).
  @visibleForTesting
  void completeCurrentTrack() {
    _handleTrackEnd();
  }

  void _handleTrackEnd() {
    if (_loopMode == RepeatMode.one) {
      _position = Duration.zero;
      _emit();
      return;
    }
    if (_currentIndex + 1 < _playlistDurations.length) {
      _currentIndex++;
      _position = Duration.zero;
      _duration = _playlistDurations[_currentIndex];
      if (!_indexController.isClosed) {
        _indexController.add(_currentIndex);
      }
      _emit();
      return;
    }
    if (_loopMode == RepeatMode.all && _playlistDurations.length > 1) {
      _currentIndex = 0;
      _position = Duration.zero;
      _duration = _playlistDurations[0];
      if (!_indexController.isClosed) {
        _indexController.add(_currentIndex);
      }
      _emit();
      return;
    }

    _position = _duration;
    _playing = false;
    _ticker?.cancel();
    _emit();
    if (!_phaseController.isClosed) {
      _phaseController.add(PlayerPhase.completed);
    }
  }

  @override
  Future<void> play() async {
    if (_playing) return;
    _playing = true;
    _phaseController.add(PlayerPhase.playing);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final stepMs = (200 * _speed).round();
      _position += Duration(milliseconds: stepMs);
      if (_position >= _duration) {
        _handleTrackEnd();
        return;
      }
      _emit();
    });
  }

  @override
  Future<void> pause() async {
    _playing = false;
    _ticker?.cancel();
    _phaseController.add(PlayerPhase.paused);
  }

  @override
  Future<void> stop() async {
    _playing = false;
    _ticker?.cancel();
    _position = Duration.zero;
    _phaseController.add(PlayerPhase.idle);
    _emit();
  }

  @override
  Future<void> seek(Duration position) async {
    final maxMs = _duration.inMilliseconds;
    final clampedMs = position.inMilliseconds.clamp(0, maxMs < 0 ? 0 : maxMs);
    _position = Duration(milliseconds: clampedMs);
    _emit();
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
  }

  @override
  Future<void> setVolume(double volume) async {}

  void _emit() {
    if (_positionController.isClosed) return;
    _positionController.add(
      PlaybackPosition(
        position: _position,
        buffered: _duration,
        duration: _duration,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _ticker?.cancel();
    await _phaseController.close();
    await _positionController.close();
    await _indexController.close();
  }
}

/// Membuat [AudioEngine] sesuai lingkungan (pengujian vs aplikasi nyata).
AudioEngine createDefaultAudioEngine() {
  // Di `flutter test`, binding adalah `TestWidgetsFlutterBinding` sehingga
  // plugin native `just_audio` tidak tersedia.
  final isTest =
      WidgetsBinding.instance.runtimeType.toString().contains('Test');
  if (isTest) {
    return SimulatedAudioEngine();
  }
  return JustAudioEngine();
}
