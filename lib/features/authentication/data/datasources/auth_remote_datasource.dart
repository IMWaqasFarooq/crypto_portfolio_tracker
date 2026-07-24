import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

/// Simulates a real backend call (latency + deterministic failure paths) so
/// the rest of the app can be built against a realistic auth contract
/// without a live server. Swap for an HTTP-backed implementation later
/// without touching the repository or any use case.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (email.toLowerCase() == 'locked@cryptofolio.dev') {
      throw const UnauthorizedException('This account has been suspended');
    }
    if (password == 'wrongpassword') {
      throw const UnauthorizedException('Incorrect email or password');
    }

    return UserModel(
      id: 'usr_${email.toLowerCase().hashCode.toUnsigned(32)}',
      email: email,
      displayName: email.split('@').first,
    );
  }
}
