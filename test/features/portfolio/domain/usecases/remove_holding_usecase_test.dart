import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/usecases/remove_holding_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late _MockPortfolioRepository repository;
  late RemoveHoldingUseCase useCase;

  setUp(() {
    repository = _MockPortfolioRepository();
    useCase = RemoveHoldingUseCase(repository);
  });

  test('delegates the holding id to the repository', () async {
    when(() => repository.removeHolding(any())).thenAnswer((_) async => const Right(null));

    final result = await useCase('1');

    expect(result, const Right<Failure, void>(null));
    verify(() => repository.removeHolding('1')).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.removeHolding(any()))
        .thenAnswer((_) async => const Left(Failure.cache()));

    final result = await useCase('1');

    expect(result, const Left<Failure, void>(Failure.cache()));
  });
}
