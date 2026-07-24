import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession({
    required UserModel user,
    required String authToken,
    required String refreshToken,
  });
  Future<UserModel?> getCachedUser();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._secureStorage, this._tokenStorage);

  final FlutterSecureStorage _secureStorage;
  final TokenStorage _tokenStorage;

  static const _userProfileKey = 'cached_user_profile';

  @override
  Future<void> cacheSession({
    required UserModel user,
    required String authToken,
    required String refreshToken,
  }) async {
    await _tokenStorage.saveTokens(authToken: authToken, refreshToken: refreshToken);
    await _secureStorage.write(key: _userProfileKey, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final token = await _tokenStorage.readAuthToken();
    if (token == null) return null;

    final raw = await _secureStorage.read(key: _userProfileKey);
    if (raw == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException('Corrupted session data');
    }
  }

  @override
  Future<void> clearSession() async {
    await _tokenStorage.clear();
    await _secureStorage.delete(key: _userProfileKey);
  }
}
