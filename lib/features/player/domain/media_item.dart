/// Jenis konten yang dapat diputar oleh pemutar tunggal (docs/04 §3, 05 §2).
enum MediaKind {
  surah,
  ayah,
  nasheed,
  adhkar,
  podcastEpisode;

  bool get supportsSkip15s =>
      this == MediaKind.podcastEpisode || this == MediaKind.adhkar;

  bool get hasReader => this == MediaKind.surah || this == MediaKind.ayah;
}

/// Asal sumber media.
enum MediaSource { api, mock, local }

/// Model media tunggal untuk semua jenis konten audio (docs/04 §3).
class MediaItem {
  const MediaItem({
    required this.id,
    required this.kind,
    required this.source,
    required this.title,
    required this.subtitle,
    required this.audioUri,
    this.duration,
    this.artwork,
    this.meta = const {},
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final durationMs = json['durationMs'];
    return MediaItem(
      id: json['id'] as String,
      kind: MediaKind.values.byName(json['kind'] as String),
      source: MediaSource.values.byName(json['source'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      audioUri: Uri.parse(json['audioUri'] as String),
      duration: durationMs is int ? Duration(milliseconds: durationMs) : null,
      artwork: json['artwork'] as String?,
      meta: (json['meta'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }

  /// Format: `"surah:55:05"`, `"ayah:55:13:05"`, `"nasheed:n-014"`, dll.
  final String id;
  final MediaKind kind;
  final MediaSource source;
  final String title;
  final String subtitle;
  final Duration? duration;
  final Uri audioUri;
  final String? artwork;
  final Map<String, Object?> meta;

  int? get surahNumber => (meta['surahNumber'] as num?)?.toInt();
  int? get ayahNumber => (meta['ayahNumber'] as num?)?.toInt();
  int? get ayahCount => (meta['ayahCount'] as num?)?.toInt();
  String? get qariId => meta['qariId'] as String?;

  MediaItem copyWith({
    MediaSource? source,
    Duration? duration,
    Uri? audioUri,
    String? artwork,
    Map<String, Object?>? meta,
  }) {
    return MediaItem(
      id: id,
      kind: kind,
      source: source ?? this.source,
      title: title,
      subtitle: subtitle,
      audioUri: audioUri ?? this.audioUri,
      duration: duration ?? this.duration,
      artwork: artwork ?? this.artwork,
      meta: meta ?? this.meta,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'source': source.name,
        'title': title,
        'subtitle': subtitle,
        'audioUri': audioUri.toString(),
        if (duration != null) 'durationMs': duration!.inMilliseconds,
        if (artwork != null) 'artwork': artwork,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MediaItem && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
