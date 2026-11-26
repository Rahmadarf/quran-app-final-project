import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

/// Memetakan exception Dio / jaringan menjadi [AppFailure] (docs/02 §7, 03 §7).
AppFailure mapToAppFailure(Object error) {
  if (error is AppFailure) return error;

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return AppFailure(AppFailureKind.timeout, cause: error);
      case DioExceptionType.connectionError:
        return AppFailure(AppFailureKind.offline, cause: error);
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        if (status == 404) {
          return AppFailure(AppFailureKind.notFound, cause: error);
        }
        if (status >= 500) {
          return AppFailure(AppFailureKind.server, cause: error);
        }
        return AppFailure(AppFailureKind.unknown, cause: error);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return AppFailure(AppFailureKind.offline, cause: error);
        }
        return AppFailure(AppFailureKind.unknown, cause: error);
    }
  }

  if (error is SocketException) {
    return AppFailure(AppFailureKind.offline, cause: error);
  }
  if (error is FormatException || error is TypeError) {
    return AppFailure(AppFailureKind.parse, cause: error);
  }

  return AppFailure(AppFailureKind.unknown, cause: error);
}
