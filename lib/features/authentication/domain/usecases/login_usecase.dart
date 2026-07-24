import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, LoginParams> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    if (params.email.trim().isEmpty || !params.email.contains('@')) {
      return Future.value(const Left(Failure.validation(message: 'Enter a valid email address')));
    }
    if (params.password.length < 6) {
      return Future.value(
        const Left(Failure.validation(message: 'Password must be at least 6 characters')),
      );
    }
    return _repository.login(email: params.email.trim(), password: params.password);
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
