import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/coin.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_coins_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late _MockMarketRepository repository;
  late GetCoinsUseCase useCase;

  setUp(() {
    repository = _MockMarketRepository();
    useCase = GetCoinsUseCase(repository);
  });

  const coins = [
    Coin(
      id: 'bitcoin',
      symbol: 'btc',
      name: 'Bitcoin',
      imageUrl: 'https://example.com/btc.png',
      currentPrice: 64000,
      marketCap: 1000000,
      marketCapRank: 1,
      priceChangePercentage24h: -1.6,
      totalVolume: 500000,
      high24h: 65000,
      low24h: 63000,
    ),
  ];

  test('fetches the requested page from the repository', () async {
    when(() => repository.getCoins(page: any(named: 'page'), perPage: any(named: 'perPage')))
        .thenAnswer((_) async => const Right(coins));

    final result = await useCase(const GetCoinsParams(page: 2, perPage: 50));

    expect(result, const Right<Failure, List<Coin>>(coins));
    verify(() => repository.getCoins(page: 2, perPage: 50)).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.getCoins(page: any(named: 'page'), perPage: any(named: 'perPage')))
        .thenAnswer((_) async => const Left(Failure.network()));

    final result = await useCase(const GetCoinsParams(page: 1));

    expect(result, const Left<Failure, List<Coin>>(Failure.network()));
  });
}
