/// Konstanta konfigurasi aplikasi (docs/02 §6).
abstract final class AppConstants {
  /// Base URL API equran.id yang terverifikasi aktif.
  static const String apiBaseUrl = 'https://equran.id/api/v2';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Qari bawaan: 05 (Misyari Rasyid Al-Afasi).
  static const String defaultQariId = '05';

  /// Batas maksimal item di dalam antrean pemutar.
  static const int maxQueueLength = 500;

  /// Batas maksimal unduhan bersamaan.
  static const int maxConcurrentDownloads = 2;

  /// Daftar kecepatan pemutaran yang tersedia.
  static const List<double> playbackSpeeds = [0.75, 1.0, 1.25, 1.5, 2.0];
}
