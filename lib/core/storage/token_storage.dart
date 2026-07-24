import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage_keys.dart';

/// Reads/writes the session token pair; lives in core since [AuthInterceptor] needs it too.
abstract class TokenStorage {
  Future<String?> readAuthToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({required String authToken, required String refreshToken});
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAuthToken() => _storage.read(key: SecureStorageKeys.authToken);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: SecureStorageKeys.refreshToken);

  @override
  Future<void> saveTokens({required String authToken, required String refreshToken}) async {
    await _storage.write(key: SecureStorageKeys.authToken, value: authToken);
    await _storage.write(key: SecureStorageKeys.refreshToken, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: SecureStorageKeys.authToken);
    await _storage.delete(key: SecureStorageKeys.refreshToken);
    await _storage.delete(key: SecureStorageKeys.loggedInUserId);
  }
}
