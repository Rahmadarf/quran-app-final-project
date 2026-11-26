import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import 'surah_dto.dart';

/// Pemanggil endpoint `equran.id/api/v2` (docs/03 §2).
class QuranApi {
  QuranApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// `GET /surat` -> daftar 114 surat.
  Future<List<SurahDto>> fetchSurahs() async {
    final response = await _client.get<Map<String, dynamic>>('/surat');
    final body = response.data;
    if (body == null || body['data'] is! List) {
      throw const AppFailure(AppFailureKind.parse);
    }
    try {
      final list = body['data'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map(SurahDto.fromJson)
          .toList(growable: false);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw AppFailure(AppFailureKind.parse, cause: e);
    }
  }

  /// `GET /surat/{nomor}` -> detail surat beserta ayat.
  Future<SurahDto> fetchSurahDetail(int number) async {
    if (number < 1 || number > 114) {
      throw const AppFailure(AppFailureKind.notFound);
    }
    final response = await _client.get<Map<String, dynamic>>('/surat/$number');
    final body = response.data;
    if (body == null || body['data'] is! Map<String, dynamic>) {
      throw const AppFailure(AppFailureKind.parse);
    }
    try {
      return SurahDto.fromJson(body['data'] as Map<String, dynamic>);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw AppFailure(AppFailureKind.parse, cause: e);
    }
  }

  /// Mengambil JSON mentah `/surat` untuk disimpan ke cache lokal.
  Future<List<dynamic>> fetchSurahsRaw() async {
    final response = await _client.get<Map<String, dynamic>>('/surat');
    final body = response.data;
    if (body == null || body['data'] is! List) {
      throw const AppFailure(AppFailureKind.parse);
    }
    return body['data'] as List<dynamic>;
  }

  /// Mengambil JSON mentah `/surat/{nomor}` untuk disimpan ke cache lokal.
  Future<Map<String, dynamic>> fetchSurahDetailRaw(int number) async {
    if (number < 1 || number > 114) {
      throw const AppFailure(AppFailureKind.notFound);
    }
    final response = await _client.get<Map<String, dynamic>>('/surat/$number');
    final body = response.data;
    if (body == null || body['data'] is! Map<String, dynamic>) {
      throw const AppFailure(AppFailureKind.parse);
    }
    return body['data'] as Map<String, dynamic>;
  }

  /// Mengambil JSON mentah `/tafsir/{nomor}` untuk disimpan ke cache lokal.
  Future<Map<String, dynamic>> fetchTafsirRaw(int number) async {
    if (number < 1 || number > 114) {
      throw const AppFailure(AppFailureKind.notFound);
    }
    final response = await _client.get<Map<String, dynamic>>('/tafsir/$number');
    final body = response.data;
    if (body == null || body['data'] is! Map<String, dynamic>) {
      throw const AppFailure(AppFailureKind.parse);
    }
    return body['data'] as Map<String, dynamic>;
  }
}
