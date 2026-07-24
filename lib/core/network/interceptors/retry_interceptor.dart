import 'package:dio/dio.dart';

import '../network_info.dart';

/// Retries idempotent GET requests with exponential backoff on transient errors.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    required this.networkInfo,
    required this.maxRetries,
    required this.baseDelay,
  });

  final Dio dio;
  final NetworkInfo networkInfo;
  final int maxRetries;
  final Duration baseDelay;

  static const _retryCountKey = 'retry_count';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isGet = options.method.toUpperCase() == 'GET';
    final retryCount = (options.extra[_retryCountKey] as int?) ?? 0;

    if (!isGet || retryCount >= maxRetries || !_isRetryable(err)) {
      handler.next(err);
      return;
    }

    if (!await networkInfo.isConnected) {
      handler.next(err);
      return;
    }

    final delay = baseDelay * (1 << retryCount); // exponential backoff
    await Future.delayed(delay);

    options.extra[_retryCountKey] = retryCount + 1;

    try {
      final response = await dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRetryable(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        return status >= 500 || status == 429;
      default:
        return false;
    }
  }
}
