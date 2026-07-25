import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_point.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_price_history_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late _MockMarketRepository repository;
  late GetPriceHistoryUseCase useCase;

  setUp(() {
    repository = _MockMarketRepository();
    useCase = GetPriceHistoryUseCase(repository);
  });

  final points = [PricePoint(timestamp: DateTime(2026, 1, 1), price: 64000)];

  test('delegates coinId and days to the repository', () async {
    when(() => repository.getPriceHistory(any(), days: any(named: 'days')))
        .thenAnswer((_) async => Right(points));

    final result = await useCase(const GetPriceHistoryParams(coinId: 'bitcoin', days: 7));

    expect(result, Right<Failure, List<PricePoint>>(points));
    verify(() => repository.getPriceHistory('bitcoin', days: 7)).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.getPriceHistory(any(), days: any(named: 'days')))
        .thenAnswer((_) async => const Left(Failure.network()));

    final result = await useCase(const GetPriceHistoryParams(coinId: 'bitcoin', days: 7));

    expect(result, const Left<Failure, List<PricePoint>>(Failure.network()));
  });
}
