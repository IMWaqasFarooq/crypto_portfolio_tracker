import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/coin_detail.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_coin_detail_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late _MockMarketRepository repository;
  late GetCoinDetailUseCase useCase;

  setUp(() {
    repository = _MockMarketRepository();
    useCase = GetCoinDetailUseCase(repository);
  });

  const detail = CoinDetail(
    id: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    imageUrl: 'https://example.com/btc.png',
    description: 'A decentralized digital currency.',
    homepageUrl: 'https://bitcoin.org',
    currentPrice: 64000,
    marketCap: 1000000,
    marketCapRank: 1,
    priceChangePercentage24h: -1.6,
    totalVolume: 500000,
    high24h: 65000,
    low24h: 63000,
    ath: 73000,
    atl: 65,
    circulatingSupply: 19000000,
    totalSupply: 21000000,
    maxSupply: 21000000,
  );

  test('delegates the coin id to the repository', () async {
    when(() => repository.getCoinDetail(any())).thenAnswer((_) async => const Right(detail));

    final result = await useCase('bitcoin');

    expect(result, const Right<Failure, CoinDetail>(detail));
    verify(() => repository.getCoinDetail('bitcoin')).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.getCoinDetail(any())).thenAnswer((_) async => const Left(Failure.server(message: 'Not found')));

    final result = await useCase('unknown-coin');

    expect(result, const Left<Failure, CoinDetail>(Failure.server(message: 'Not found')));
  });
}
