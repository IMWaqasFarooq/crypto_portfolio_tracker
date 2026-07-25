import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/candle.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_candles_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late _MockMarketRepository repository;
  late GetCandlesUseCase useCase;

  setUp(() {
    repository = _MockMarketRepository();
    useCase = GetCandlesUseCase(repository);
  });

  final candles = [
    Candle(timestamp: DateTime(2026, 1, 1), open: 63000, high: 65000, low: 62000, close: 64000),
  ];

  test('delegates coinId and days to the repository', () async {
    when(() => repository.getCandles(any(), days: any(named: 'days')))
        .thenAnswer((_) async => Right(candles));

    final result = await useCase(const GetCandlesParams(coinId: 'bitcoin', days: 30));

    expect(result, Right<Failure, List<Candle>>(candles));
    verify(() => repository.getCandles('bitcoin', days: 30)).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.getCandles(any(), days: any(named: 'days')))
        .thenAnswer((_) async => const Left(Failure.network()));

    final result = await useCase(const GetCandlesParams(coinId: 'bitcoin', days: 30));

    expect(result, const Left<Failure, List<Candle>>(Failure.network()));
  });
}
