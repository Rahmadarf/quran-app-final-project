import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/quran_repository.dart';
import '../domain/surah.dart';
import '../domain/tafsir.dart';
import 'quran_api.dart';
import 'surah_dto.dart';

/// Status kesegaran data yang dikembalikan oleh [QuranRepositoryImpl].
enum QuranDataFreshness {
  fresh,
  cached,
  offlineFallback,
}

/// Implementasi [QuranRepository] dengan cache memori + disk sederhana
/// (`SharedPreferences`) dengan kunci versi `v1` (docs/03 §5).
class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl({QuranApi? api}) : _api = api ?? QuranApi();

  final QuranApi _api;

  QuranDataFreshness _surahsFreshness = QuranDataFreshness.fresh;
  QuranDataFreshness _detailFreshness = QuranDataFreshness.fresh;

  QuranDataFreshness get surahsFreshness => _surahsFreshness;
  QuranDataFreshness get detailFreshness => _detailFreshness;

  static const String _surahListCacheKey = 'quran_cache_v1_surahs';
  static String _surahDetailCacheKey(int n) => 'quran_cache_v1_surah_$n';
  static String _tafsirCacheKey(int n) => 'quran_cache_v1_tafsir_$n';

  List<Surah>? _surahListMemory;
  final Map<int, Surah> _surahDetailMemory = {};
  final Map<int, SurahTafsir> _tafsirMemory = {};

  @override
  Future<List<Surah>> getSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh && _surahListMemory != null) {
      return _surahListMemory!;
    }

    final prefs = await _safePrefs();
    if (!forceRefresh && prefs != null) {
      final cachedJson = prefs.getString(_surahListCacheKey);
      if (cachedJson != null) {
        try {
          final parsed = _decodeSurahList(cachedJson);
          _surahListMemory = parsed;
          _surahsFreshness = QuranDataFreshness.cached;
          return parsed;
        } catch (_) {
          // Abaikan cache rusak dan lanjut ambil dari API.
        }
      }
    }

    try {
      final rawList = await _api.fetchSurahsRaw();
      final parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => SurahDto.fromJson(e).toDomain())
          .toList(growable: false);
      _surahListMemory = parsed;
      _surahsFreshness = QuranDataFreshness.fresh;
      await prefs?.setString(_surahListCacheKey, jsonEncode(rawList));
      return parsed;
    } catch (e) {
      if (_surahListMemory != null) {
        _surahsFreshness = QuranDataFreshness.offlineFallback;
        return _surahListMemory!;
      }
      if (prefs != null) {
        final cachedJson = prefs.getString(_surahListCacheKey);
        if (cachedJson != null) {
          try {
            final parsed = _decodeSurahList(cachedJson);
            _surahListMemory = parsed;
            _surahsFreshness = QuranDataFreshness.offlineFallback;
            return parsed;
          } catch (_) {}
        }
      }
      rethrow;
    }
  }

  @override
  Future<Surah> getSurahDetail(int number, {bool forceRefresh = false}) async {
    if (number < 1 || number > 114) {
      throw const AppFailure(AppFailureKind.notFound);
    }
    if (!forceRefresh && _surahDetailMemory.containsKey(number)) {
      return _surahDetailMemory[number]!;
    }

    final prefs = await _safePrefs();
    if (!forceRefresh && prefs != null) {
      final cachedJson = prefs.getString(_surahDetailCacheKey(number));
      if (cachedJson != null) {
        try {
          final parsed = await compute(_decodeSurahDetail, cachedJson);
          _cacheDetailInMemory(number, parsed);
          _detailFreshness = QuranDataFreshness.cached;
          return parsed;
        } catch (_) {
          // Abaikan cache rusak.
        }
      }
    }

    try {
      final rawMap = await _api.fetchSurahDetailRaw(number);
      final encoded = jsonEncode(rawMap);
      final parsed = await compute(_decodeSurahDetail, encoded);
      _cacheDetailInMemory(number, parsed);
      _detailFreshness = QuranDataFreshness.fresh;
      await prefs?.setString(_surahDetailCacheKey(number), encoded);
      return parsed;
    } catch (e) {
      if (_surahDetailMemory.containsKey(number)) {
        _detailFreshness = QuranDataFreshness.offlineFallback;
        return _surahDetailMemory[number]!;
      }
      if (prefs != null) {
        final cachedJson = prefs.getString(_surahDetailCacheKey(number));
        if (cachedJson != null) {
          try {
            final parsed = await compute(_decodeSurahDetail, cachedJson);
            _cacheDetailInMemory(number, parsed);
            _detailFreshness = QuranDataFreshness.offlineFallback;
            return parsed;
          } catch (_) {}
        }
      }
      rethrow;
    }
  }

  @override
  Future<SurahTafsir> getTafsir(int number, {bool forceRefresh = false}) async {
    if (number < 1 || number > 114) {
      throw const AppFailure(AppFailureKind.notFound);
    }
    if (!forceRefresh && _tafsirMemory.containsKey(number)) {
      return _tafsirMemory[number]!;
    }

    final prefs = await _safePrefs();
    if (!forceRefresh && prefs != null) {
      final cachedJson = prefs.getString(_tafsirCacheKey(number));
      if (cachedJson != null) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          final parsed = SurahTafsir.fromJson(decoded);
          _tafsirMemory[number] = parsed;
          return parsed;
        } catch (_) {
          // Abaikan cache rusak.
        }
      }
    }

    try {
      final rawMap = await _api.fetchTafsirRaw(number);
      final parsed = SurahTafsir.fromJson(rawMap);
      _tafsirMemory[number] = parsed;
      await prefs?.setString(_tafsirCacheKey(number), jsonEncode(rawMap));
      return parsed;
    } catch (e) {
      if (_tafsirMemory.containsKey(number)) return _tafsirMemory[number]!;
      rethrow;
    }
  }

  void _cacheDetailInMemory(int number, Surah surah) {
    // Simpan maksimal 5 surat terakhir di memori (docs/03 §5).
    if (_surahDetailMemory.length >= 5 &&
        !_surahDetailMemory.containsKey(number)) {
      _surahDetailMemory.remove(_surahDetailMemory.keys.first);
    }
    _surahDetailMemory[number] = surah;
  }

  Future<SharedPreferences?> _safePrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  static List<Surah> _decodeSurahList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Expected List');
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((e) => SurahDto.fromJson(e).toDomain())
        .toList(growable: false);
  }
}

Surah _decodeSurahDetail(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Expected Map');
  }
  return SurahDto.fromJson(decoded).toDomain();
}
