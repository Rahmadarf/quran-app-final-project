/// Model domain ayat Al-Qur'an (docs/03 §4).
///
/// [arabic] dan [translation] disimpan persis seperti respons API tanpa
/// diubah, dipotong, atau dinormalisasi (docs/06 §6).
class Ayah {
  const Ayah({
    required this.surahNumber,
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.audio,
  });

  final int surahNumber;
  final int number;
  final String arabic;
  final String transliteration;
  final String translation;
  final Map<String, Uri> audio;

  Uri? audioForQari(String qariId) => audio[qariId];
}
