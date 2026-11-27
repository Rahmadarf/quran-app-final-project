import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/network/failure_mapper.dart';
import '../../player/application/player_controller.dart';
import '../../player/domain/media_item.dart';
import '../../quran/data/quran_repository_impl.dart';
import '../../quran/domain/ayah.dart';
import '../../quran/domain/quran_repository.dart';
import '../../quran/domain/surah.dart';
import '../../quran/domain/tafsir.dart';
import '../domain/bookmark.dart';
import '../domain/reader_settings.dart';
import 'sync_engine.dart';

/// Catatan posisi baca terakhir untuk fitur "Lanjutkan membaca" (docs/06 §7).
class LastReadPosition {
  const LastReadPosition({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.updatedAt,
  });

  factory LastReadPosition.fromJson(Map<String, dynamic> json) {
    return LastReadPosition(
      surahNumber: (json['surahNumber'] as num).toInt(),
      surahName: (json['surahName'] as String?) ?? '',
      ayahNumber: (json['ayahNumber'] as num).toInt(),
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'ayahNumber': ayahNumber,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Pengendali state Reader: memuat surat & Basmalah dari API, mengatur
/// tampilan persisten, penanda, tafsir, dan sinkronisasi audio (docs/06).
class ReaderController extends ChangeNotifier {
  ReaderController({
    QuranRepository? repository,
    SyncEngine? syncEngine,
  })  : _repository = repository ?? QuranRepositoryImpl(),
        _syncEngine = syncEngine ?? const SyncEngine();

  static const String _settingsKey = 'reader_settings_v1';
  static const String _bookmarksKey = 'reader_bookmarks_v1';
  static const String _lastReadKey = 'reader_last_read_v1';

  final QuranRepository _repository;
  final SyncEngine _syncEngine;

  ReaderSettings _settings = const ReaderSettings();
  List<AyahBookmark> _bookmarks = const [];
  LastReadPosition? _lastRead;

  List<Surah> _surahs = const [];
  bool _loadingSurahs = false;
  AppFailure? _surahsError;

  Surah? _currentSurah;
  Ayah? _basmalahAyah;
  bool _loadingSurahDetail = false;
  AppFailure? _surahDetailError;

  final Map<int, SurahTafsir> _tafsirCache = {};
  QuranDataFreshness _surahsFreshness = QuranDataFreshness.fresh;
  QuranDataFreshness _detailFreshness = QuranDataFreshness.fresh;
  bool _disposed = false;

  QuranRepository get repository => _repository;
  SyncEngine get syncEngine => _syncEngine;
  ReaderSettings get settings => _settings;
  List<AyahBookmark> get bookmarks => List.unmodifiable(_bookmarks);
  LastReadPosition? get lastRead => _lastRead;

  List<Surah> get surahs => _surahs;
  bool get loadingSurahs => _loadingSurahs;
  AppFailure? get surahsError => _surahsError;
  QuranDataFreshness get surahsFreshness => _surahsFreshness;
  bool get isSurahsOffline =>
      _surahsFreshness == QuranDataFreshness.offlineFallback;
  bool get isSurahsStale => _surahsFreshness == QuranDataFreshness.cached;

  Surah? get currentSurah => _currentSurah;
  Ayah? get basmalahAyah => _basmalahAyah;
  bool get loadingSurahDetail => _loadingSurahDetail;
  AppFailure? get surahDetailError => _surahDetailError;
  QuranDataFreshness get detailFreshness => _detailFreshness;
  bool get isDetailOffline =>
      _detailFreshness == QuranDataFreshness.offlineFallback;
  bool get isDetailStale => _detailFreshness == QuranDataFreshness.cached;

  @visibleForTesting
  void setDataFreshnessForTest({
    QuranDataFreshness? surahs,
    QuranDataFreshness? detail,
  }) {
    if (surahs != null) _surahsFreshness = surahs;
    if (detail != null) _detailFreshness = detail;
    _safeNotify();
  }

  /// Aturan Basmalah (docs/06 §1):
  /// - Surat 1: tidak ada kepala Basmalah (ayat 1 sudah Basmalah)
  /// - Surat 2–114 kecuali 9: tampilkan kepala Basmalah dari ayat 1 Al-Fatihah
  /// - Surat 9: tidak ada Basmalah
  bool shouldShowBasmalahHeader(int surahNumber) =>
      surahNumber != 1 && surahNumber != 9;

  bool isBookmarked(int surahNumber, int ayahNumber) =>
      _bookmarks.any((b) => b.id == '$surahNumber:$ayahNumber');

  /// Memulihkan pengaturan tampilan, penanda, dan riwayat baca terakhir.
  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawSettings = prefs.getString(_settingsKey);
      if (rawSettings != null) {
        _settings = ReaderSettings.fromJson(
          jsonDecode(rawSettings) as Map<String, dynamic>,
        );
      }
      final rawBookmarks = prefs.getString(_bookmarksKey);
      if (rawBookmarks != null) {
        final list = jsonDecode(rawBookmarks) as List;
        _bookmarks = list
            .whereType<Map<String, dynamic>>()
            .map(AyahBookmark.fromJson)
            .toList(growable: false);
      }
      final rawLastRead = prefs.getString(_lastReadKey);
      if (rawLastRead != null) {
        _lastRead = LastReadPosition.fromJson(
          jsonDecode(rawLastRead) as Map<String, dynamic>,
        );
      }
      _safeNotify();
    } catch (_) {
      // Abaikan data korup.
    }
  }

  /// Memuat daftar 114 surat dari cache/API.
  Future<void> loadSurahs({bool forceRefresh = false}) async {
    if (_loadingSurahs) return;
    _loadingSurahs = true;
    _surahsError = null;
    _safeNotify();

    try {
      _surahs = await _repository.getSurahs(forceRefresh: forceRefresh);
      if (_repository is QuranRepositoryImpl) {
        _surahsFreshness = _repository.surahsFreshness;
      }
    } catch (e) {
      _surahsError = mapToAppFailure(e);
    } finally {
      _loadingSurahs = false;
      _safeNotify();
    }
  }

  /// Memuat detail surat dan teks Basmalah (dari ayat 1 Al-Fatihah API).
  Future<void> loadSurah(int surahNumber, {bool forceRefresh = false}) async {
    _loadingSurahDetail = true;
    _surahDetailError = null;
    if (_currentSurah?.number != surahNumber) {
      _currentSurah = null;
    }
    _safeNotify();

    try {
      final detail = await _repository.getSurahDetail(
        surahNumber,
        forceRefresh: forceRefresh,
      );
      if (shouldShowBasmalahHeader(surahNumber) && _basmalahAyah == null) {
        try {
          final fatihah = await _repository.getSurahDetail(1);
          if (fatihah.ayat.isNotEmpty) {
            _basmalahAyah = fatihah.ayat.first;
          }
        } catch (_) {
          // Biarkan null bila gagal memuat Al-Fatihah.
        }
      } else if (surahNumber == 1 && detail.ayat.isNotEmpty) {
        _basmalahAyah = detail.ayat.first;
      }

      _currentSurah = detail;
      if (_repository is QuranRepositoryImpl) {
        _detailFreshness = _repository.detailFreshness;
      }
    } catch (e) {
      _surahDetailError = mapToAppFailure(e);
    } finally {
      _loadingSurahDetail = false;
      _safeNotify();
    }
  }

  /// Memuat tafsir untuk [surahNumber].
  Future<SurahTafsir> loadTafsir(int surahNumber) async {
    if (_tafsirCache.containsKey(surahNumber)) {
      return _tafsirCache[surahNumber]!;
    }
    final tafsir = await _repository.getTafsir(surahNumber);
    _tafsirCache[surahNumber] = tafsir;
    return tafsir;
  }

  /// Memulai pemutaran dari [ayahNumber] sesuai mode sinkronisasi aktif.
  Future<void> playFromAyah(
    PlayerController player,
    Surah surah,
    int ayahNumber, {
    String? qariId,
    String? qariName,
  }) async {
    final targetQari = qariId ?? player.selectedQariId;
    final displayQari = qariName ?? _qariName(targetQari);

    if (_settings.syncMode == SyncMode.perAyah && surah.ayat.isNotEmpty) {
      // Jika daftar putar per ayat untuk surat & qari ini sudah aktif, cukup
      // lompat instan ke ayat tujuan tanpa memuat ulang playlist.
      final cur = player.state.current;
      if (cur != null &&
          cur.kind == MediaKind.ayah &&
          cur.surahNumber == surah.number &&
          cur.qariId == targetQari) {
        final jumped = await player.jumpToAyah(ayahNumber);
        if (jumped) {
          unawaited(saveLastRead(surah.number, surah.latinName, ayahNumber));
          return;
        }
      }

      final items = <MediaItem>[];
      for (final ayah in surah.ayat) {
        final uri = ayah.audioForQari(targetQari);
        if (uri == null) continue;
        items.add(
          MediaItem(
            id: 'ayah:${surah.number}:${ayah.number}:$targetQari',
            kind: MediaKind.ayah,
            source: MediaSource.api,
            title: 'Surat ${surah.latinName} · Ayat ${ayah.number}',
            subtitle: displayQari,
            audioUri: uri,
            meta: {
              'surahNumber': surah.number,
              'surahLatinName': surah.latinName,
              'surahArabicName': surah.arabicName,
              'ayahNumber': ayah.number,
              'ayahCount': surah.ayahCount,
              'qariId': targetQari,
            },
          ),
        );
      }

      if (items.isNotEmpty) {
        final foundIdx = items.indexWhere((e) => e.ayahNumber == ayahNumber);
        final startIdx =
            foundIdx >= 0 ? foundIdx : (ayahNumber - 1).clamp(0, items.length - 1);
        await player.playAyahPlaylist(
          items,
          startIndex: startIdx,
          queueSource: '${surah.latinName} · Per Ayat',
        );
        unawaited(saveLastRead(surah.number, surah.latinName, ayahNumber));
        return;
      }
    }

    // Mode B: audio surat penuh + lompat ke perkiraan waktu mulai ayat.
    await player.playSurah(
      surah.number,
      qariId: targetQari,
      qariName: displayQari,
      preferPerAyah: false,
      queueSource: '${surah.latinName} · Surat Penuh',
    );
    final total = player.position.duration;
    if (ayahNumber > 1 && total != null && total.inMilliseconds > 0) {
      final targetPos = _syncEngine.startTimeForAyah(surah, ayahNumber, total);
      await player.seekTo(targetPos);
    }
    unawaited(saveLastRead(surah.number, surah.latinName, ayahNumber));
  }

  /// Mengganti mode sinkronisasi (Mode A ↔ Mode B) dan mempertahankan ayat aktif.
  Future<void> switchSyncMode(
    SyncMode mode,
    PlayerController player, {
    int currentActiveAyah = 1,
  }) async {
    if (_settings.syncMode == mode) return;
    await updateSettings(_settings.copyWith(syncMode: mode));
    final surah = _currentSurah;
    if (surah != null && player.state.current?.surahNumber == surah.number) {
      await playFromAyah(player, surah, currentActiveAyah);
    }
  }

  Future<void> updateSettings(ReaderSettings next) async {
    _settings = next;
    _safeNotify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(next.toJson()));
    } catch (_) {}
  }

  Future<void> toggleBookmark(Surah surah, Ayah ayah) async {
    final id = '${surah.number}:${ayah.number}';
    final existingIdx = _bookmarks.indexWhere((b) => b.id == id);
    final next = List<AyahBookmark>.of(_bookmarks);
    if (existingIdx >= 0) {
      next.removeAt(existingIdx);
    } else {
      next.insert(
        0,
        AyahBookmark(
          surahNumber: surah.number,
          surahName: surah.latinName,
          ayahNumber: ayah.number,
          arabic: ayah.arabic,
          translation: ayah.translation,
          createdAt: DateTime.now(),
        ),
      );
    }
    _bookmarks = next;
    _safeNotify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _bookmarksKey,
        jsonEncode(next.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> saveLastRead(
    int surahNumber,
    String surahName,
    int ayahNumber,
  ) async {
    _lastRead = LastReadPosition(
      surahNumber: surahNumber,
      surahName: surahName,
      ayahNumber: ayahNumber,
      updatedAt: DateTime.now(),
    );
    _safeNotify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastReadKey, jsonEncode(_lastRead!.toJson()));
    } catch (_) {}
  }

  String _qariName(String qariId) {
    const names = {
      '01': 'Abdullah Al-Juhany',
      '02': 'Abdul Muhsin Al-Qasim',
      '03': 'Abdurrahman As-Sudais',
      '04': 'Ibrahim Al-Dossari',
      '05': 'Misyari Rasyid Al-Afasi',
      '06': 'Yasser Al-Dosari',
    };
    return names[qariId] ?? 'Qari ${AppConstants.defaultQariId}';
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
