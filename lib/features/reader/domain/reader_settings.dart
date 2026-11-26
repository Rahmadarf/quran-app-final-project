/// Mode tata letak Reader (docs/06 §3).
enum ReaderMode {
  translation('Terjemahan'),
  mushaf('Mode baca');

  const ReaderMode(this.label);
  final String label;
}

/// Mode sinkronisasi teks & audio (docs/06 §4).
enum SyncMode {
  /// Mode A: antrean per ayat (sinkronisasi nyata).
  perAyah('Sorot per ayat (akurat)'),

  /// Mode B: audio surat penuh (waktu perkiraan / mock sync).
  fullSurah('Audio penuh (mulus)');

  const SyncMode(this.label);
  final String label;
}

/// Pengaturan tampilan Reader yang bertahan lokal (docs/06 §3.3).
class ReaderSettings {
  const ReaderSettings({
    this.mode = ReaderMode.translation,
    this.arabicSizeLevel = 3,
    this.translationSizeLevel = 2,
    this.showTransliteration = false,
    this.showTranslation = true,
    this.autoScroll = true,
    this.syncMode = SyncMode.perAyah,
  });

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      mode: ReaderMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => ReaderMode.translation,
      ),
      arabicSizeLevel:
          ((json['arabicSizeLevel'] as num?)?.toInt() ?? 3).clamp(1, 5),
      translationSizeLevel:
          ((json['translationSizeLevel'] as num?)?.toInt() ?? 2).clamp(1, 3),
      showTransliteration: (json['showTransliteration'] as bool?) ?? false,
      showTranslation: (json['showTranslation'] as bool?) ?? true,
      autoScroll: (json['autoScroll'] as bool?) ?? true,
      syncMode: SyncMode.values.firstWhere(
        (m) => m.name == json['syncMode'],
        orElse: () => SyncMode.perAyah,
      ),
    );
  }

  final ReaderMode mode;

  /// Tingkat 1..5 (~22..42 sp), bawaan 3.
  final int arabicSizeLevel;

  /// Tingkat 1..3 (kecil/sedang/besar), bawaan 2.
  final int translationSizeLevel;

  final bool showTransliteration;
  final bool showTranslation;
  final bool autoScroll;
  final SyncMode syncMode;

  /// Ukuran huruf Arab dalam sp berdasarkan [arabicSizeLevel] (20, 24, 28, 34, 40).
  double get arabicFontSize {
    const sizes = [20.0, 24.0, 28.0, 34.0, 40.0];
    return sizes[(arabicSizeLevel - 1).clamp(0, 4)];
  }

  /// Ukuran huruf terjemahan dalam sp berdasarkan [translationSizeLevel].
  double get translationFontSize {
    const sizes = [12.5, 14.0, 16.5];
    return sizes[(translationSizeLevel - 1).clamp(0, 2)];
  }

  ReaderSettings copyWith({
    ReaderMode? mode,
    int? arabicSizeLevel,
    int? translationSizeLevel,
    bool? showTransliteration,
    bool? showTranslation,
    bool? autoScroll,
    SyncMode? syncMode,
  }) {
    return ReaderSettings(
      mode: mode ?? this.mode,
      arabicSizeLevel: arabicSizeLevel ?? this.arabicSizeLevel,
      translationSizeLevel: translationSizeLevel ?? this.translationSizeLevel,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      autoScroll: autoScroll ?? this.autoScroll,
      syncMode: syncMode ?? this.syncMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'arabicSizeLevel': arabicSizeLevel,
        'translationSizeLevel': translationSizeLevel,
        'showTransliteration': showTransliteration,
        'showTranslation': showTranslation,
        'autoScroll': autoScroll,
        'syncMode': syncMode.name,
      };
}
