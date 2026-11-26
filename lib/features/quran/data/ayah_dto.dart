import '../domain/ayah.dart';

const Set<String> validQariKeys = {'01', '02', '03', '04', '05', '06'};

/// Memetakan objek `audio` / `audioFull` dari JSON equran.id; kunci asing
/// diabaikan dan nilai kosong/tidak valid dilewati (docs/03 §4).
Map<String, Uri> parseQariAudioMap(Object? raw) {
  if (raw is! Map) return const {};
  final result = <String, Uri>{};
  for (final entry in raw.entries) {
    final key = entry.key.toString();
    if (!validQariKeys.contains(key)) continue;
    final url = entry.value?.toString().trim() ?? '';
    if (url.isEmpty) continue;
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      result[key] = uri;
    }
  }
  return Map.unmodifiable(result);
}

/// DTO ayat sesuai JSON equran.id (docs/03 §2.2).
class AyahDto {
  const AyahDto({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory AyahDto.fromJson(Map<String, dynamic> json) {
    return AyahDto(
      nomorAyat: (json['nomorAyat'] as num).toInt(),
      teksArab: json['teksArab'] as String,
      teksLatin: (json['teksLatin'] as String?) ?? '',
      teksIndonesia: json['teksIndonesia'] as String,
      audio: parseQariAudioMap(json['audio']),
    );
  }

  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, Uri> audio;

  Ayah toDomain(int surahNumber) => Ayah(
        surahNumber: surahNumber,
        number: nomorAyat,
        arabic: teksArab,
        transliteration: teksLatin,
        translation: teksIndonesia,
        audio: audio,
      );
}
