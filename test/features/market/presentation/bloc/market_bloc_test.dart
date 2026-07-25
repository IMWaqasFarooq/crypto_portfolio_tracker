import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/core/services/currency_provider.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/coin.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_tick.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_coins_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/watch_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/market_bloc.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/market_event.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/market_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCoinsUseCase extends Mock implements GetCoinsUseCase {}

class _MockWatchPriceUpdatesUseCase extends Mock implements WatchPriceUpdatesUseCase {}

class _MockUnsubscribePriceUpdatesUseCase extends Mock implements UnsubscribePriceUpdatesUseCase {}

class _MockCurrencyProvider extends Mock implements CurrencyProvider {}

Coin _coin(String id, String symbol) => Coin(
      id: id,
      symbol: symbol,
      name: id,
      imageUrl: 'https://example.com/$id.png',
      currentPrice: 100,
      marketCap: 1000,
      marketCapRank: 1,
      priceChangePercentage24h: 1,
      totalVolume: 500,
      high24h: 110,
      low24h: 90,
    );

void main() {
  late _MockGetCoinsUseCase getCoinsUseCase;
  late _MockWatchPriceUpdatesUseCase watchPriceUpdatesUseCase;
  late _MockUnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase;
  late _MockCurrencyProvider currencyProvider;

  setUpAll(() {
    registerFallbackValue(const GetCoinsParams(page: 1));
    registerFallbackValue(const WatchPriceUpdatesParams(subscriberId: '', symbols: []));
  });

  setUp(() {
    getCoinsUseCase = _MockGetCoinsUseCase();
    watchPriceUpdatesUseCase = _MockWatchPriceUpdatesUseCase();
    unsubscribePriceUpdatesUseCase = _MockUnsubscribePriceUpdatesUseCase();
    currencyProvider = _MockCurrencyProvider();

    when(() => currencyProvider.watch()).thenAnswer((_) => const Stream.empty());
    when(() => currencyProvider.currencyCode).thenReturn('usd');
    when(() => watchPriceUpdatesUseCase(any())).thenAnswer((_) => const Stream.empty());
    when(() => unsubscribePriceUpdatesUseCase(any())).thenReturn(null);
  });

  MarketBloc buildBloc() => MarketBloc(
        getCoinsUseCase: getCoinsUseCase,
        watchPriceUpdatesUseCase: watchPriceUpdatesUseCase,
        unsubscribePriceUpdatesUseCase: unsubscribePriceUpdatesUseCase,
        currencyProvider: currencyProvider,
      );

  final coins = [_coin('bitcoin', 'btc'), _coin('ethereum', 'eth')];

  blocTest<MarketBloc, MarketState>(
    'emits [loading, success] with the first page on started',
    build: () {
      when(() => getCoinsUseCase(any())).thenAnswer((_) async => Right(coins));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const MarketEvent.started()),
    expect: () => [
      const MarketState(status: MarketStatus.loading),
      MarketState(status: MarketStatus.success, coins: coins, currentPage: 1, hasMore: false),
    ],
  );

  blocTest<MarketBloc, MarketState>(
    'emits [loading, failure] when the first page fails to load',
    build: () {
      when(() => getCoinsUseCase(any())).thenAnswer((_) async => const Left(Failure.network()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const MarketEvent.started()),
    expect: () => [
      const MarketState(status: MarketStatus.loading),
      const MarketState(status: MarketStatus.failure, failure: Failure.network()),
    ],
  );

  blocTest<MarketBloc, MarketState>(
    'subscribes to live ticks when the display currency is USD',
    build: () {
      when(() => getCoinsUseCase(any())).thenAnswer((_) async => Right(coins));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const MarketEvent.started()),
    verify: (_) => verify(() => watchPriceUpdatesUseCase(any())).called(1),
  );

  blocTest<MarketBloc, MarketState>(
    'does not subscribe to live ticks when the display currency is not USD',
    build: () {
      when(() => currencyProvider.currencyCode).thenReturn('eur');
      when(() => getCoinsUseCase(any())).thenAnswer((_) async => Right(coins));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const MarketEvent.started()),
    verify: (_) => verifyNever(() => watchPriceUpdatesUseCase(any())),
  );

  blocTest<MarketBloc, MarketState>(
    'appends the next page on loadMoreRequested',
    build: () {
      when(() => getCoinsUseCase(any())).thenAnswer((_) async => Right(coins));
      return buildBloc();
    },
    seed: () => MarketState(status: MarketStatus.success, coins: coins, currentPage: 1, hasMore: true),
    act: (bloc) => bloc.add(const MarketEvent.loadMoreRequested()),
    expect: () => [
      MarketState(status: MarketStatus.success, coins: coins, currentPage: 1, isLoadingMore: true, hasMore: true),
      MarketState(
        status: MarketStatus.success,
        coins: [...coins, ...coins],
        currentPage: 2,
        hasMore: false,
      ),
    ],
  );

  blocTest<MarketBloc, MarketState>(
    'ignores loadMoreRequested when there is no more data',
    build: () {
      when(() => getCoinsUseCase(any())).thenAnswer((_) async => Right(coins));
      return buildBloc();
    },
    seed: () => MarketState(status: MarketStatus.success, coins: coins, hasMore: false),
    act: (bloc) => bloc.add(const MarketEvent.loadMoreRequested()),
    expect: () => <MarketState>[],
    verify: (_) => verifyNever(() => getCoinsUseCase(any())),
  );

  blocTest<MarketBloc, MarketState>(
    'updates the matching coin in place on priceTickReceived',
    build: buildBloc,
    seed: () => MarketState(status: MarketStatus.success, coins: coins),
    act: (bloc) => bloc.add(
      const MarketEvent.priceTickReceived(PriceTick(symbol: 'btc', price: 70000, changePercent24h: 5)),
    ),
    expect: () => [
      MarketState(
        status: MarketStatus.success,
        coins: [coins[0].withLiveTick(const PriceTick(symbol: 'btc', price: 70000, changePercent24h: 5)), coins[1]],
        liveSymbols: const {'btc'},
      ),
    ],
  );

  blocTest<MarketBloc, MarketState>(
    'ignores a price tick for a symbol not currently in the list',
    build: buildBloc,
    seed: () => MarketState(status: MarketStatus.success, coins: coins),
    act: (bloc) => bloc.add(
      const MarketEvent.priceTickReceived(PriceTick(symbol: 'doge', price: 1, changePercent24h: 5)),
    ),
    expect: () => <MarketState>[],
  );
}
