import '../../../core/errors/app_failure.dart';
import '../domain/media_item.dart';

/// Hasil resolusi sumber audio yang siap dimuat oleh mesin audio.
class ResolvedAudioSource {
  const ResolvedAudioSource({
    required this.uri,
    required this.isLocal,
    required this.isAsset,
  });

  final Uri uri;
  final bool isLocal;
  final bool isAsset;
}

/// Memilih sumber audio terbaik untuk [MediaItem] (docs/05 §7):
/// 1. Berkas unduhan lokal (bila tersedia),
/// 2. Stream jaringan (atau aset bundel untuk item tiruan),
/// 3. Gagal dengan [AppFailureKind.notDownloaded] bila offline & belum diunduh.
class AudioSourceResolver {
  const AudioSourceResolver({
    this._localFileLookup,
    this._isOnlineCheck,
  });

  final Future<Uri?> Function(String mediaId)? _localFileLookup;
  final Future<bool> Function()? _isOnlineCheck;

  Future<ResolvedAudioSource> resolve(MediaItem item) async {
    if (_localFileLookup != null) {
      final localUri = await _localFileLookup(item.id);
      if (localUri != null) {
        return ResolvedAudioSource(uri: localUri, isLocal: true, isAsset: false);
      }
    }

    if (item.source == MediaSource.local || item.audioUri.scheme == 'file') {
      return ResolvedAudioSource(
        uri: item.audioUri,
        isLocal: true,
        isAsset: false,
      );
    }

    if (item.source == MediaSource.mock || item.audioUri.scheme == 'asset') {
      return ResolvedAudioSource(
        uri: item.audioUri,
        isLocal: false,
        isAsset: true,
      );
    }

    if (_isOnlineCheck != null) {
      final online = await _isOnlineCheck();
      if (!online) {
        throw const AppFailure(AppFailureKind.notDownloaded);
      }
    }

    return ResolvedAudioSource(
      uri: item.audioUri,
      isLocal: false,
      isAsset: false,
    );
  }
}
