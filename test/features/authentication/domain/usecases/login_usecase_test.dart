import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/entities/user.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/repositories/auth_repository.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/usecases/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  const user = User(id: '1', email: 'demo@cryptofolio.dev', displayName: 'Demo');

  test('delegates to the repository when email and password are valid', () async {
    when(() => repository.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => const Right(user));

    final result = await useCase(
      const LoginParams(email: 'demo@cryptofolio.dev', password: 'password123'),
    );

    expect(result, const Right<Failure, User>(user));
    verify(() => repository.login(email: 'demo@cryptofolio.dev', password: 'password123')).called(1);
  });

  test('trims whitespace from the email before delegating', () async {
    when(() => repository.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => const Right(user));

    await useCase(const LoginParams(email: '  demo@cryptofolio.dev  ', password: 'password123'));

    verify(() => repository.login(email: 'demo@cryptofolio.dev', password: 'password123')).called(1);
  });

  test('rejects an empty email without calling the repository', () async {
    final result = await useCase(const LoginParams(email: '', password: 'password123'));

    expect(result, isA<Left<Failure, User>>());
    verifyNever(() => repository.login(email: any(named: 'email'), password: any(named: 'password')));
  });

  test('rejects an email missing an @ without calling the repository', () async {
    final result = await useCase(const LoginParams(email: 'not-an-email', password: 'password123'));

    expect(result, isA<Left<Failure, User>>());
    verifyNever(() => repository.login(email: any(named: 'email'), password: any(named: 'password')));
  });

  test('rejects a password shorter than 6 characters without calling the repository', () async {
    final result = await useCase(const LoginParams(email: 'demo@cryptofolio.dev', password: '123'));

    expect(result, isA<Left<Failure, User>>());
    verifyNever(() => repository.login(email: any(named: 'email'), password: any(named: 'password')));
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => const Left(Failure.server(message: 'Bad credentials')));

    final result = await useCase(
      const LoginParams(email: 'demo@cryptofolio.dev', password: 'password123'),
    );

    expect(result, const Left<Failure, User>(Failure.server(message: 'Bad credentials')));
  });
}
