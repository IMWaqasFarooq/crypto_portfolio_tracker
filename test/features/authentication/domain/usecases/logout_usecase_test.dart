import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/core/usecase/usecase.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/repositories/auth_repository.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LogoutUseCase(repository);
  });

  test('delegates to the repository and returns success', () async {
    when(() => repository.logout()).thenAnswer((_) async => const Right(null));

    final result = await useCase(const NoParams());

    expect(result, const Right<Failure, void>(null));
    verify(() => repository.logout()).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.logout())
        .thenAnswer((_) async => const Left(Failure.cache(message: 'Could not clear session')));

    final result = await useCase(const NoParams());

    expect(result, const Left<Failure, void>(Failure.cache(message: 'Could not clear session')));
  });
}
