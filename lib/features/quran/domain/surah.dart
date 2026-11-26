import 'ayah.dart';

/// Tempat turunnya surat.
enum Revelation {
  makkiyah('Mekah'),
  madaniyah('Madinah');

  const Revelation(this.label);
  final String label;

  static Revelation fromApi(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('madin')) return Revelation.madaniyah;
    return Revelation.makkiyah;
  }
}

/// Referensi ringkas surat sebelum/sesudah pada detail surat.
class SurahRef {
  const SurahRef({
    required this.number,
    required this.arabicName,
    required this.latinName,
    required this.ayahCount,
  });

  final int number;
  final String arabicName;
  final String latinName;
  final int ayahCount;
}

/// Model domain surat Al-Qur'an (docs/03 §4).
class Surah {
  const Surah({
    required this.number,
    required this.arabicName,
    required this.latinName,
    required this.meaning,
    required this.revelation,
    required this.ayahCount,
    required this.descriptionPlain,
    required this.fullAudio,
    this.ayat = const [],
    this.previousSurah,
    this.nextSurah,
  });

  final int number;
  final String arabicName;
  final String latinName;
  final String meaning;
  final Revelation revelation;
  final int ayahCount;
  final String descriptionPlain;
  final Map<String, Uri> fullAudio;
  final List<Ayah> ayat;
  final SurahRef? previousSurah;
  final SurahRef? nextSurah;

  Uri? fullAudioForQari(String qariId) => fullAudio[qariId];
}
