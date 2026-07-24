import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// Attaches the bearer token; opt out per-request via `extra['requiresAuth'] = false`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra['requiresAuth'] as bool? ?? true;
    if (requiresAuth) {
      final token = await _tokenStorage.readAuthToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
