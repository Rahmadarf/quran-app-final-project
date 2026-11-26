/// Penanda ayat lokal (docs/06 §7).
class AyahBookmark {
  const AyahBookmark({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabic,
    required this.translation,
    required this.createdAt,
  });

  factory AyahBookmark.fromJson(Map<String, dynamic> json) {
    return AyahBookmark(
      surahNumber: (json['surahNumber'] as num).toInt(),
      surahName: (json['surahName'] as String?) ?? '',
      ayahNumber: (json['ayahNumber'] as num).toInt(),
      arabic: (json['arabic'] as String?) ?? '',
      translation: (json['translation'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabic;
  final String translation;
  final DateTime createdAt;

  String get id => '$surahNumber:$ayahNumber';

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'ayahNumber': ayahNumber,
        'arabic': arabic,
        'translation': translation,
        'createdAt': createdAt.toIso8601String(),
      };
}
