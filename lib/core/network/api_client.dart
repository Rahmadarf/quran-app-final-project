import 'package:dio/dio.dart';

import '../../app/constants.dart';
import 'failure_mapper.dart';

/// Klien HTTP untuk API equran.id dengan timeout dan coba ulang otomatis
/// maksimal 2 kali untuk `timeout` dan `5xx` (docs/02 §7).
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.apiBaseUrl,
                connectTimeout: AppConstants.connectTimeout,
                receiveTimeout: AppConstants.receiveTimeout,
                headers: const {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;

  static const int _maxRetries = 2;

  /// Melakukan permintaan `GET` ke [path] dengan retry bertahap untuk error
  /// sementara (`timeout` atau status `5xx`).
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await _dio.get<T>(
          path,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
        );
      } on DioException catch (e) {
        final shouldRetry = _isRetryable(e) && attempt < _maxRetries;
        if (!shouldRetry) {
          throw mapToAppFailure(e);
        }
        attempt++;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      } catch (e) {
        throw mapToAppFailure(e);
      }
    }
  }

  bool _isRetryable(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    final status = e.response?.statusCode ?? 0;
    return status >= 500 && status < 600;
  }
}
