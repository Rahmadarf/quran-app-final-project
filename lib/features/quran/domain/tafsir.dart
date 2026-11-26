/// Satu entri tafsir per ayat dari `GET /tafsir/{nomor}` (docs/03 §2.5).
class TafsirEntry {
  const TafsirEntry({
    required this.startAyah,
    required this.endAyah,
    required this.text,
  });

  final int startAyah;
  final int endAyah;
  final String text;

  bool coversAyah(int ayahNumber) =>
      ayahNumber >= startAyah && ayahNumber <= endAyah;

  /// Mengonversi field `ayat` (string atau int, bisa tunggal `"1"` atau rentang
  /// `"1-2"`) menjadi [TafsirEntry] tanpa crash untuk masukan tak terduga.
  static TafsirEntry? tryParse(Map<String, dynamic> json) {
    final rawAyat = json['ayat']?.toString().trim() ?? '';
    final teks = json['teks']?.toString() ?? '';
    if (rawAyat.isEmpty || teks.isEmpty) return null;

    final match = RegExp(r'^(\d+)(?:\s*[-–]\s*(\d+))?$').firstMatch(rawAyat);
    if (match == null) return null;

    final start = int.tryParse(match.group(1)!);
    final end = match.group(2) != null ? int.tryParse(match.group(2)!) : start;
    if (start == null || end == null || start <= 0 || end < start) {
      return null;
    }

    return TafsirEntry(startAyah: start, endAyah: end, text: teks);
  }
}

/// Kumpulan tafsir satu surat.
class SurahTafsir {
  const SurahTafsir({
    required this.surahNumber,
    required this.entries,
  });

  factory SurahTafsir.fromJson(Map<String, dynamic> json) {
    final surahNumber = (json['nomor'] as num?)?.toInt() ?? 0;
    final rawList = json['tafsir'];
    final entries = <TafsirEntry>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          final parsed = TafsirEntry.tryParse(item);
          if (parsed != null) entries.add(parsed);
        }
      }
    }
    return SurahTafsir(surahNumber: surahNumber, entries: entries);
  }

  final int surahNumber;
  final List<TafsirEntry> entries;

  TafsirEntry? forAyah(int ayahNumber) {
    for (final entry in entries) {
      if (entry.coversAyah(ayahNumber)) return entry;
    }
    return null;
  }
}
