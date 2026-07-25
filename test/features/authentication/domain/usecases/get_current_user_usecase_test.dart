import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/core/usecase/usecase.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/entities/user.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/repositories/auth_repository.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = GetCurrentUserUseCase(repository);
  });

  const user = User(id: '1', email: 'demo@cryptofolio.dev', displayName: 'Demo');

  test('returns the cached user when a session exists', () async {
    when(() => repository.getCurrentUser()).thenAnswer((_) async => const Right(user));

    final result = await useCase(const NoParams());

    expect(result, const Right<Failure, User?>(user));
  });

  test('returns null when no session exists', () async {
    when(() => repository.getCurrentUser()).thenAnswer((_) async => const Right(null));

    final result = await useCase(const NoParams());

    expect(result, const Right<Failure, User?>(null));
  });
}
