import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/coin_search_result.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/search_coins_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late _MockMarketRepository repository;
  late SearchCoinsUseCase useCase;

  setUp(() {
    repository = _MockMarketRepository();
    useCase = SearchCoinsUseCase(repository);
  });

  const results = [
    CoinSearchResult(
      id: 'bitcoin',
      symbol: 'btc',
      name: 'Bitcoin',
      thumbnailUrl: 'https://example.com/btc-thumb.png',
      marketCapRank: 1,
    ),
  ];

  test('delegates the query to the repository', () async {
    when(() => repository.searchCoins(any())).thenAnswer((_) async => const Right(results));

    final result = await useCase('bitcoin');

    expect(result, const Right<Failure, List<CoinSearchResult>>(results));
    verify(() => repository.searchCoins('bitcoin')).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.searchCoins(any())).thenAnswer((_) async => const Left(Failure.network()));

    final result = await useCase('bitcoin');

    expect(result, const Left<Failure, List<CoinSearchResult>>(Failure.network()));
  });
}
