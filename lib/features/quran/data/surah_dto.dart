import '../domain/surah.dart';
import 'ayah_dto.dart';

/// DTO surat sesuai JSON equran.id `/surat` dan `/surat/{nomor}` (docs/03 §2).
class SurahDto {
  const SurahDto({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
    this.ayat = const [],
    this.suratSebelumnya,
    this.suratSelanjutnya,
  });

  factory SurahDto.fromJson(Map<String, dynamic> json) {
    final rawAyat = json['ayat'];
    final ayatList = rawAyat is List
        ? rawAyat
            .whereType<Map<String, dynamic>>()
            .map(AyahDto.fromJson)
            .toList(growable: false)
        : const <AyahDto>[];

    return SurahDto(
      nomor: (json['nomor'] as num).toInt(),
      nama: json['nama'] as String,
      namaLatin: json['namaLatin'] as String,
      jumlahAyat: (json['jumlahAyat'] as num).toInt(),
      tempatTurun: (json['tempatTurun'] as String?) ?? 'Mekah',
      arti: (json['arti'] as String?) ?? '',
      deskripsi: (json['deskripsi'] as String?) ?? '',
      audioFull: parseQariAudioMap(json['audioFull']),
      ayat: ayatList,
      suratSebelumnya: _parseRef(json['suratSebelumnya']),
      suratSelanjutnya: _parseRef(json['suratSelanjutnya']),
    );
  }

  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, Uri> audioFull;
  final List<AyahDto> ayat;
  final SurahRef? suratSebelumnya;
  final SurahRef? suratSelanjutnya;

  Surah toDomain() => Surah(
        number: nomor,
        arabicName: nama,
        latinName: namaLatin,
        meaning: arti,
        revelation: Revelation.fromApi(tempatTurun),
        ayahCount: jumlahAyat,
        descriptionPlain: _stripHtml(deskripsi),
        fullAudio: audioFull,
        ayat: ayat.map((a) => a.toDomain(nomor)).toList(growable: false),
        previousSurah: suratSebelumnya,
        nextSurah: suratSelanjutnya,
      );

  static SurahRef? _parseRef(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final nomor = raw['nomor'];
    final nama = raw['nama'];
    final namaLatin = raw['namaLatin'];
    final jumlahAyat = raw['jumlahAyat'];
    if (nomor is! num || nama is! String || namaLatin is! String) return null;
    return SurahRef(
      number: nomor.toInt(),
      arabicName: nama,
      latinName: namaLatin,
      ayahCount: jumlahAyat is num ? jumlahAyat.toInt() : 0,
    );
  }

  /// Membersihkan tag HTML dari `deskripsi` API (docs/02 §8, 03 §4).
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</?(?:i|em|b|strong|p)[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();
  }
}
