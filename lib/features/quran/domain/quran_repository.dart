import 'surah.dart';
import 'tafsir.dart';

/// Kontrak repositori data Al-Qur'an (docs/02 §3).
abstract interface class QuranRepository {
  /// Mengambil daftar 114 surat (dari cache atau API).
  Future<List<Surah>> getSurahs({bool forceRefresh = false});

  /// Mengambil detail surat beserta seluruh ayat dan tautan audio.
  Future<Surah> getSurahDetail(int number, {bool forceRefresh = false});

  /// Mengambil tafsir per ayat satu surat dari `/tafsir/{nomor}`.
  Future<SurahTafsir> getTafsir(int number, {bool forceRefresh = false});
}
