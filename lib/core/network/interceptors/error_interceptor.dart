import 'dart:io';

import 'package:dio/dio.dart';

import '../../error/exceptions.dart';

/// Normalizes Dio failures into our own [Exception] types.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = _mapError(err);
    handler.next(
      err.copyWith(error: mapped),
    );
  }

  Exception _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('The request timed out');
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badCertificate:
        return const NetworkException('Insecure connection rejected');
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled');
      case DioExceptionType.badResponse:
        return _mapBadResponse(err);
      case DioExceptionType.unknown:
        if (err.error is SocketException) return const NetworkException();
        return ServerException(message: err.message ?? 'Unknown network error');
      default:
        return ServerException(message: err.message ?? 'Unknown network error');
    }
  }

  Exception _mapBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    final message = _extractMessage(data) ?? 'Server error ($statusCode)';

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedException(message);
    }
    if (statusCode == 429) {
      return ServerException(message: 'Rate limit exceeded, please slow down', statusCode: statusCode);
    }
    if (statusCode != null && statusCode >= 500) {
      return ServerException(message: 'Server is currently unavailable', statusCode: statusCode);
    }
    return ServerException(message: message, statusCode: statusCode);
  }

  String? _extractMessage(dynamic data) {
    if (data is Map && data['error'] != null) return data['error'].toString();
    if (data is Map && data['message'] != null) return data['message'].toString();
    return null;
  }
}
