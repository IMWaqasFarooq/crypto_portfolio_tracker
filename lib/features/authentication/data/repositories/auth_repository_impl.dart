import 'package:dartz/dartz.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    try {
      final userModel = await remoteDataSource.login(email: email, password: password);
      await localDataSource.cacheSession(
        user: userModel,
        authToken: _mockToken(userModel),
        refreshToken: '${_mockToken(userModel)}_refresh',
      );
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cached = await localDataSource.getCachedUser();
      return Right(cached?.toEntity());
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }

  String _mockToken(UserModel user) => 'mock_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
}
