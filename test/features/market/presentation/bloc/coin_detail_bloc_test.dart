import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/core/services/currency_provider.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/candle.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/coin_detail.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_point.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_tick.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_candles_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/get_price_history_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/watch_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/coin_detail_bloc.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/coin_detail_event.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/coin_detail_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCoinDetailUseCase extends Mock implements GetCoinDetailUseCase {}

class _MockGetPriceHistoryUseCase extends Mock implements GetPriceHistoryUseCase {}

class _MockGetCandlesUseCase extends Mock implements GetCandlesUseCase {}

class _MockWatchPriceUpdatesUseCase extends Mock implements WatchPriceUpdatesUseCase {}

class _MockUnsubscribePriceUpdatesUseCase extends Mock implements UnsubscribePriceUpdatesUseCase {}

class _MockCurrencyProvider extends Mock implements CurrencyProvider {}

const _detail = CoinDetail(
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

void main() {
  late _MockGetCoinDetailUseCase getCoinDetailUseCase;
  late _MockGetPriceHistoryUseCase getPriceHistoryUseCase;
  late _MockGetCandlesUseCase getCandlesUseCase;
  late _MockWatchPriceUpdatesUseCase watchPriceUpdatesUseCase;
  late _MockUnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase;
  late _MockCurrencyProvider currencyProvider;

  setUpAll(() {
    registerFallbackValue(const WatchPriceUpdatesParams(subscriberId: '', symbols: []));
    registerFallbackValue(const GetPriceHistoryParams(coinId: '', days: 1));
    registerFallbackValue(const GetCandlesParams(coinId: '', days: 1));
  });

  setUp(() {
    getCoinDetailUseCase = _MockGetCoinDetailUseCase();
    getPriceHistoryUseCase = _MockGetPriceHistoryUseCase();
    getCandlesUseCase = _MockGetCandlesUseCase();
    watchPriceUpdatesUseCase = _MockWatchPriceUpdatesUseCase();
    unsubscribePriceUpdatesUseCase = _MockUnsubscribePriceUpdatesUseCase();
    currencyProvider = _MockCurrencyProvider();

    when(() => currencyProvider.currencyCode).thenReturn('usd');
    when(() => watchPriceUpdatesUseCase(any())).thenAnswer((_) => const Stream.empty());
    when(() => unsubscribePriceUpdatesUseCase(any())).thenReturn(null);
    when(() => getCoinDetailUseCase(any())).thenAnswer((_) async => const Right(_detail));
    when(() => getPriceHistoryUseCase(any())).thenAnswer(
      (_) async => Right([PricePoint(timestamp: DateTime(2026, 1, 1), price: 64000)]),
    );
    when(() => getCandlesUseCase(any())).thenAnswer(
      (_) async => Right([
        Candle(timestamp: DateTime(2026, 1, 1), open: 63000, high: 65000, low: 62000, close: 64000),
      ]),
    );
  });

  CoinDetailBloc buildBloc() => CoinDetailBloc(
        getCoinDetailUseCase: getCoinDetailUseCase,
        getPriceHistoryUseCase: getPriceHistoryUseCase,
        getCandlesUseCase: getCandlesUseCase,
        watchPriceUpdatesUseCase: watchPriceUpdatesUseCase,
        unsubscribePriceUpdatesUseCase: unsubscribePriceUpdatesUseCase,
        currencyProvider: currencyProvider,
      );

  blocTest<CoinDetailBloc, CoinDetailState>(
    'loads the coin detail and the line chart on started',
    build: buildBloc,
    act: (bloc) => bloc.add(const CoinDetailEvent.started('bitcoin')),
    expect: () => [
      const CoinDetailState(detailStatus: DetailStatus.loading, chartStatus: ChartStatus.loading),
      const CoinDetailState(
        detailStatus: DetailStatus.success,
        coin: _detail,
        chartStatus: ChartStatus.loading,
      ),
      CoinDetailState(
        detailStatus: DetailStatus.success,
        coin: _detail,
        chartStatus: ChartStatus.success,
        pricePoints: [PricePoint(timestamp: DateTime(2026, 1, 1), price: 64000)],
      ),
    ],
  );

  blocTest<CoinDetailBloc, CoinDetailState>(
    'emits a detail failure when the coin fails to load',
    build: () {
      when(() => getCoinDetailUseCase(any()))
          .thenAnswer((_) async => const Left(Failure.server(message: 'Not found')));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const CoinDetailEvent.started('unknown')),
    expect: () => [
      const CoinDetailState(detailStatus: DetailStatus.loading, chartStatus: ChartStatus.loading),
      const CoinDetailState(
        detailStatus: DetailStatus.failure,
        detailFailure: Failure.server(message: 'Not found'),
        chartStatus: ChartStatus.loading,
      ),
      CoinDetailState(
        detailStatus: DetailStatus.failure,
        detailFailure: const Failure.server(message: 'Not found'),
        chartStatus: ChartStatus.success,
        pricePoints: [PricePoint(timestamp: DateTime(2026, 1, 1), price: 64000)],
      ),
    ],
  );

  blocTest<CoinDetailBloc, CoinDetailState>(
    'fetches candles instead of the line history after switching chart type',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const CoinDetailEvent.started('bitcoin'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const CoinDetailEvent.chartTypeChanged(ChartType.candles));
    },
    skip: 3,
    expect: () => [
      CoinDetailState(
        detailStatus: DetailStatus.success,
        coin: _detail,
        chartStatus: ChartStatus.loading,
        chartType: ChartType.candles,
        pricePoints: [PricePoint(timestamp: DateTime(2026, 1, 1), price: 64000)],
      ),
      CoinDetailState(
        detailStatus: DetailStatus.success,
        coin: _detail,
        chartStatus: ChartStatus.success,
        chartType: ChartType.candles,
        pricePoints: [PricePoint(timestamp: DateTime(2026, 1, 1), price: 64000)],
        candles: [
          Candle(timestamp: DateTime(2026, 1, 1), open: 63000, high: 65000, low: 62000, close: 64000),
        ],
      ),
    ],
    verify: (_) => verify(() => getPriceHistoryUseCase(any())).called(1),
  );

  blocTest<CoinDetailBloc, CoinDetailState>(
    'applies a live price tick on top of the current coin',
    build: buildBloc,
    seed: () => const CoinDetailState(detailStatus: DetailStatus.success, coin: _detail),
    act: (bloc) => bloc.add(
      const CoinDetailEvent.priceTickReceived(PriceTick(symbol: 'btc', price: 70000, changePercent24h: 5)),
    ),
    expect: () => [
      CoinDetailState(
        detailStatus: DetailStatus.success,
        coin: _detail.withLiveTick(const PriceTick(symbol: 'btc', price: 70000, changePercent24h: 5)),
        isLive: true,
      ),
    ],
  );

  blocTest<CoinDetailBloc, CoinDetailState>(
    'does not subscribe to live ticks when the display currency is not USD',
    build: () {
      when(() => currencyProvider.currencyCode).thenReturn('eur');
      return buildBloc();
    },
    act: (bloc) => bloc.add(const CoinDetailEvent.started('bitcoin')),
    verify: (_) => verifyNever(() => watchPriceUpdatesUseCase(any())),
  );
}
