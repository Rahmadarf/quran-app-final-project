/// Jenis kegagalan aplikasi yang dipetakan dari lapisan data (docs/02 §7).
enum AppFailureKind {
  offline,
  timeout,
  notFound,
  server,
  parse,
  storageFull,
  notDownloaded,
  unknown,
}

/// Representasi error yang aman ditampilkan ke pengguna dalam Bahasa Indonesia.
class AppFailure implements Exception {
  const AppFailure(
    this.kind, {
    String? message,
    this.cause,
  }) : _customMessage = message;

  final AppFailureKind kind;
  final String? _customMessage;
  final Object? cause;

  /// Pesan ramah berbahasa Indonesia tanpa detail teknis mentah.
  String get userMessage => _customMessage ?? defaultMessageFor(kind);

  static String defaultMessageFor(AppFailureKind kind) {
    switch (kind) {
      case AppFailureKind.offline:
        return 'Kamu sedang offline. Periksa koneksi internetmu, lalu coba lagi.';
      case AppFailureKind.timeout:
        return 'Koneksi ke server terlalu lama. Periksa jaringan, lalu coba lagi.';
      case AppFailureKind.notFound:
        return 'Konten yang diminta tidak ditemukan.';
      case AppFailureKind.server:
        return 'Server sedang bermasalah. Coba beberapa saat lagi.';
      case AppFailureKind.parse:
        return 'Data tidak dapat dibaca dengan benar. Silakan coba lagi.';
      case AppFailureKind.storageFull:
        return 'Penyimpanan perangkat penuh. Hapus beberapa unduhan lalu coba lagi.';
      case AppFailureKind.notDownloaded:
        return 'Belum diunduh. Hubungkan internet atau unduh dulu.';
      case AppFailureKind.unknown:
        return 'Terjadi kendala. Silakan coba lagi.';
    }
  }

  @override
  String toString() => 'AppFailure($kind: $userMessage)';
}
