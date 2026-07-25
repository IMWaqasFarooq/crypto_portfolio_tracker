import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/entities/holding.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/usecases/add_holding_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late _MockPortfolioRepository repository;
  late AddHoldingUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      Holding(
        id: '1',
        coinId: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        imageUrl: 'https://example.com/btc.png',
        quantity: 0.5,
        averageBuyPrice: 60000,
        purchaseDate: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    repository = _MockPortfolioRepository();
    useCase = AddHoldingUseCase(repository);
  });

  final holding = Holding(
    id: '1',
    coinId: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    imageUrl: 'https://example.com/btc.png',
    quantity: 0.5,
    averageBuyPrice: 60000,
    purchaseDate: DateTime(2026, 1, 1),
  );

  test('delegates the holding to the repository', () async {
    when(() => repository.addHolding(any())).thenAnswer((_) async => const Right(null));

    final result = await useCase(holding);

    expect(result, const Right<Failure, void>(null));
    verify(() => repository.addHolding(holding)).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.addHolding(any()))
        .thenAnswer((_) async => const Left(Failure.cache(message: 'Could not save holding')));

    final result = await useCase(holding);

    expect(result, const Left<Failure, void>(Failure.cache(message: 'Could not save holding')));
  });
}
