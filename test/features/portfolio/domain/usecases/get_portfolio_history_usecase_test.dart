import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_point.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_price_history_usecase.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/entities/holding.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/usecases/get_portfolio_history_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPriceHistoryUseCase extends Mock implements GetPriceHistoryUseCase {}

Holding _holding(String coinId, double quantity) => Holding(
      id: coinId,
      coinId: coinId,
      symbol: coinId,
      name: coinId,
      imageUrl: 'https://example.com/$coinId.png',
      quantity: quantity,
      averageBuyPrice: 100,
      purchaseDate: DateTime(2026, 1, 1),
    );

void main() {
  late _MockGetPriceHistoryUseCase getPriceHistoryUseCase;
  late GetPortfolioHistoryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const GetPriceHistoryParams(coinId: '', days: 1));
  });

  setUp(() {
    getPriceHistoryUseCase = _MockGetPriceHistoryUseCase();
    useCase = GetPortfolioHistoryUseCase(getPriceHistoryUseCase);
  });

  test('returns an empty series without fetching anything when there are no holdings', () async {
    final result = await useCase(const GetPortfolioHistoryParams(holdings: [], days: 7));

    expect(result, const Right<Failure, List<PricePoint>>([]));
    verifyNever(() => getPriceHistoryUseCase(any()));
  });

  test('sums quantity-weighted value across holdings at each timestamp', () async {
    final t0 = DateTime(2026, 1, 1);
    final t1 = DateTime(2026, 1, 2);

    when(() => getPriceHistoryUseCase(const GetPriceHistoryParams(coinId: 'bitcoin', days: 7)))
        .thenAnswer(
      (_) async => Right([
        PricePoint(timestamp: t0, price: 100),
        PricePoint(timestamp: t1, price: 200),
      ]),
    );
    when(() => getPriceHistoryUseCase(const GetPriceHistoryParams(coinId: 'ethereum', days: 7)))
        .thenAnswer(
      (_) async => Right([
        PricePoint(timestamp: t0, price: 10),
        PricePoint(timestamp: t1, price: 20),
      ]),
    );

    final result = await useCase(
      GetPortfolioHistoryParams(holdings: [_holding('bitcoin', 2), _holding('ethereum', 5)], days: 7),
    );

    result.fold(
      (failure) => fail('expected a successful result, got $failure'),
      (points) {
        expect(points, [
          PricePoint(timestamp: t0, price: 2 * 100 + 5 * 10),
          PricePoint(timestamp: t1, price: 2 * 200 + 5 * 20),
        ]);
      },
    );
  });

  test('truncates to the shortest history when coins have mismatched lengths', () async {
    final t0 = DateTime(2026, 1, 1);
    final t1 = DateTime(2026, 1, 2);

    when(() => getPriceHistoryUseCase(const GetPriceHistoryParams(coinId: 'bitcoin', days: 7)))
        .thenAnswer(
      (_) async => Right([
        PricePoint(timestamp: t0, price: 100),
        PricePoint(timestamp: t1, price: 200),
      ]),
    );
    when(() => getPriceHistoryUseCase(const GetPriceHistoryParams(coinId: 'ethereum', days: 7)))
        .thenAnswer((_) async => Right([PricePoint(timestamp: t0, price: 10)]));

    final result = await useCase(
      GetPortfolioHistoryParams(holdings: [_holding('bitcoin', 1), _holding('ethereum', 1)], days: 7),
    );

    result.fold(
      (failure) => fail('expected a successful result, got $failure'),
      (points) => expect(points, [PricePoint(timestamp: t0, price: 110)]),
    );
  });

  test('propagates a failure if any coin history fails to load', () async {
    when(() => getPriceHistoryUseCase(const GetPriceHistoryParams(coinId: 'bitcoin', days: 7)))
        .thenAnswer((_) async => const Left(Failure.network()));

    final result = await useCase(
      GetPortfolioHistoryParams(holdings: [_holding('bitcoin', 1)], days: 7),
    );

    expect(result, const Left<Failure, List<PricePoint>>(Failure.network()));
  });
}
