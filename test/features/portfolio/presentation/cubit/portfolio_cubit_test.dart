import 'dart:async';

import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_tick.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/watch_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/entities/holding.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/usecases/add_holding_usecase.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/usecases/remove_holding_usecase.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/usecases/watch_holdings_usecase.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchHoldingsUseCase extends Mock implements WatchHoldingsUseCase {}

class _MockAddHoldingUseCase extends Mock implements AddHoldingUseCase {}

class _MockRemoveHoldingUseCase extends Mock implements RemoveHoldingUseCase {}

class _MockWatchPriceUpdatesUseCase extends Mock implements WatchPriceUpdatesUseCase {}

class _MockUnsubscribePriceUpdatesUseCase extends Mock implements UnsubscribePriceUpdatesUseCase {}

Holding _holding(String symbol) => Holding(
      id: symbol,
      coinId: symbol,
      symbol: symbol,
      name: symbol,
      imageUrl: 'https://example.com/$symbol.png',
      quantity: 1,
      averageBuyPrice: 100,
      purchaseDate: DateTime(2026, 1, 1),
    );

void main() {
  late _MockWatchHoldingsUseCase watchHoldingsUseCase;
  late _MockAddHoldingUseCase addHoldingUseCase;
  late _MockRemoveHoldingUseCase removeHoldingUseCase;
  late _MockWatchPriceUpdatesUseCase watchPriceUpdatesUseCase;
  late _MockUnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase;
  late StreamController<List<Holding>> holdingsController;

  setUpAll(() {
    registerFallbackValue(const WatchPriceUpdatesParams(subscriberId: '', symbols: []));
    registerFallbackValue(
      Holding(
        id: '1',
        coinId: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        imageUrl: 'https://example.com/btc.png',
        quantity: 1,
        averageBuyPrice: 100,
        purchaseDate: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    watchHoldingsUseCase = _MockWatchHoldingsUseCase();
    addHoldingUseCase = _MockAddHoldingUseCase();
    removeHoldingUseCase = _MockRemoveHoldingUseCase();
    watchPriceUpdatesUseCase = _MockWatchPriceUpdatesUseCase();
    unsubscribePriceUpdatesUseCase = _MockUnsubscribePriceUpdatesUseCase();
    holdingsController = StreamController<List<Holding>>.broadcast();

    when(() => watchHoldingsUseCase()).thenAnswer((_) => holdingsController.stream);
    when(() => watchPriceUpdatesUseCase(any())).thenAnswer((_) => const Stream.empty());
    when(() => unsubscribePriceUpdatesUseCase(any())).thenReturn(null);
  });

  tearDown(() => holdingsController.close());

  PortfolioCubit buildCubit() => PortfolioCubit(
        watchHoldingsUseCase: watchHoldingsUseCase,
        addHoldingUseCase: addHoldingUseCase,
        removeHoldingUseCase: removeHoldingUseCase,
        watchPriceUpdatesUseCase: watchPriceUpdatesUseCase,
        unsubscribePriceUpdatesUseCase: unsubscribePriceUpdatesUseCase,
      );

  test('emits success with the holdings list and subscribes to live ticks', () async {
    final cubit = buildCubit();
    final holdings = [_holding('btc')];

    holdingsController.add(holdings);
    await pumpEventQueue();

    expect(cubit.state, PortfolioState(status: PortfolioStatus.success, holdings: holdings));
    verify(() => watchPriceUpdatesUseCase(
          const WatchPriceUpdatesParams(subscriberId: 'portfolio', symbols: ['btc']),
        )).called(1);

    await cubit.close();
  });

  test('does not subscribe to live ticks when holdings become empty', () async {
    final cubit = buildCubit();

    holdingsController.add(const []);
    await pumpEventQueue();

    expect(cubit.state.status, PortfolioStatus.success);
    verifyNever(() => watchPriceUpdatesUseCase(any()));

    await cubit.close();
  });

  test('merges incoming live ticks into state', () async {
    final tickController = StreamController<PriceTick>.broadcast();
    when(() => watchPriceUpdatesUseCase(any())).thenAnswer((_) => tickController.stream);

    final cubit = buildCubit();
    holdingsController.add([_holding('btc')]);
    await pumpEventQueue();

    const tick = PriceTick(symbol: 'btc', price: 70000, changePercent24h: 5);
    tickController.add(tick);
    await pumpEventQueue();

    expect(cubit.state.liveTicks, {'btc': tick});

    await tickController.close();
    await cubit.close();
  });

  test('addHolding delegates to the use case', () async {
    when(() => addHoldingUseCase(any())).thenAnswer((_) async => const Right(null));
    final cubit = buildCubit();

    final result = await cubit.addHolding(
      coinId: 'bitcoin',
      symbol: 'btc',
      name: 'Bitcoin',
      imageUrl: 'https://example.com/btc.png',
      quantity: 1,
      averageBuyPrice: 60000,
    );

    expect(result, const Right<Failure, void>(null));
    verify(() => addHoldingUseCase(any())).called(1);

    await cubit.close();
  });

  test('removeHolding delegates to the use case', () async {
    when(() => removeHoldingUseCase(any())).thenAnswer((_) async => const Right(null));
    final cubit = buildCubit();

    final result = await cubit.removeHolding('1');

    expect(result, const Right<Failure, void>(null));
    verify(() => removeHoldingUseCase('1')).called(1);

    await cubit.close();
  });
}
