import '../../player/domain/media_item.dart';
import '../../player/domain/player_state.dart';
import '../../quran/domain/ayah.dart';
import '../../quran/domain/surah.dart';

/// Hasil perhitungan [SyncEngine] untuk ayat yang sedang aktif.
class SyncResult {
  const SyncResult({
    this.activeAyah,
    this.progressInAyah = 0,
    this.isEstimated = false,
  });

  /// Nomor ayat (1-based) yang sedang disorot, atau `null` bila tidak ada.
  final int? activeAyah;
  final double progressInAyah;
  final bool isEstimated;
}

/// Mesin sinkronisasi teks Al-Qur'an dan posisi audio (docs/06 §4).
///
/// Tidak memutar audio dan tidak mengubah teks Arab/terjemahan.
class SyncEngine {
  const SyncEngine({this.pauseWeightPerAyah = 4.0});

  /// Bobot jeda tetap antarayat (setara ±0,3 detik).
  final double pauseWeightPerAyah;

  static const int _basmalahBaseLetters = 19;

  /// Menentukan ayat aktif berdasarkan [current] item, [pos], dan [surah].
  SyncResult resolve({
    required Surah surah,
    required MediaItem? current,
    required PlaybackPosition pos,
  }) {
    if (current == null || surah.ayat.isEmpty) {
      return const SyncResult();
    }
    if (current.surahNumber != surah.number) {
      return const SyncResult();
    }

    // Mode A: per ayat (sinkronisasi nyata).
    if (current.kind == MediaKind.ayah) {
      final ayahNo = current.ayahNumber;
      if (ayahNo == null || ayahNo < 1 || ayahNo > surah.ayahCount) {
        return const SyncResult();
      }
      return SyncResult(
        activeAyah: ayahNo,
        progressInAyah: pos.progress,
        isEstimated: false,
      );
    }

    // Mode B: surat penuh (waktu perkiraan / mock sync).
    if (current.kind == MediaKind.surah) {
      final duration = pos.duration ?? current.duration;
      if (duration == null || duration.inMilliseconds <= 0) {
        return const SyncResult(activeAyah: 1, isEstimated: true);
      }

      final boundaries = computeAyahStartTimes(
        surah.ayat,
        duration,
        includeBasmalahHeader: surah.number != 1 && surah.number != 9,
      );
      if (boundaries.isEmpty) return const SyncResult();

      final clampedMs = pos.position.inMilliseconds.clamp(
        0,
        duration.inMilliseconds,
      );
      final idx = _binarySearchIndex(boundaries, clampedMs);
      final ayah = surah.ayat[idx];
      final startMs = boundaries[idx].inMilliseconds;
      final endMs = idx + 1 < boundaries.length
          ? boundaries[idx + 1].inMilliseconds
          : duration.inMilliseconds;
      final span = (endMs - startMs).clamp(1, duration.inMilliseconds);
      final localProgress = ((clampedMs - startMs) / span).clamp(0.0, 1.0);

      return SyncResult(
        activeAyah: ayah.number,
        progressInAyah: localProgress,
        isEstimated: true,
      );
    }

    return const SyncResult();
  }

  /// Menghitung waktu mulai perkiraan (`mulai(ayat_i)`) untuk setiap ayat
  /// pada Mode B (docs/06 §4.2).
  List<Duration> computeAyahStartTimes(
    List<Ayah> ayat,
    Duration totalDuration, {
    bool includeBasmalahHeader = false,
  }) {
    if (ayat.isEmpty || totalDuration.inMilliseconds <= 0) return const [];

    final basmalahWeight = includeBasmalahHeader
        ? (_basmalahBaseLetters + pauseWeightPerAyah)
        : 0.0;

    final weights = <double>[];
    var totalWeight = basmalahWeight;
    for (final ayah in ayat) {
      final w = countBaseArabicLetters(ayah.arabic) + pauseWeightPerAyah;
      weights.add(w);
      totalWeight += w;
    }
    if (totalWeight <= 0) {
      return List.filled(ayat.length, Duration.zero);
    }

    final totalMs = totalDuration.inMilliseconds;
    final starts = <Duration>[];
    var acc = basmalahWeight;
    for (var i = 0; i < ayat.length; i++) {
      final startMs = (totalMs * (acc / totalWeight)).round();
      starts.add(Duration(milliseconds: startMs.clamp(0, totalMs)));
      acc += weights[i];
    }
    return starts;
  }

  /// Mengembalikan perkiraan posisi mulai untuk [ayahNumber] (1-based) pada Mode B.
  Duration startTimeForAyah(
    Surah surah,
    int ayahNumber,
    Duration totalDuration,
  ) {
    final starts = computeAyahStartTimes(
      surah.ayat,
      totalDuration,
      includeBasmalahHeader: surah.number != 1 && surah.number != 9,
    );
    final idx = (ayahNumber - 1).clamp(0, starts.length - 1);
    return starts.isEmpty ? Duration.zero : starts[idx];
  }

  /// Menghitung jumlah huruf dasar Arab (tanpa harakat/tanda waqaf) tanpa
  /// mengubah string asli (docs/06 §4.2, §6).
  static int countBaseArabicLetters(String text) {
    var count = 0;
    for (final rune in text.runes) {
      // Rentang huruf dasar Arab (Hamzah..Ya dan huruf Arab tambahan).
      final isBaseLetter = (rune >= 0x0621 && rune <= 0x063A) ||
          (rune >= 0x0641 && rune <= 0x064A) ||
          (rune >= 0x0671 && rune <= 0x06D3);
      if (isBaseLetter) count++;
    }
    return count;
  }

  int _binarySearchIndex(List<Duration> starts, int targetMs) {
    var low = 0;
    var high = starts.length - 1;
    while (low < high) {
      final mid = (low + high + 1) >> 1;
      if (starts[mid].inMilliseconds <= targetMs) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return low;
  }
}
