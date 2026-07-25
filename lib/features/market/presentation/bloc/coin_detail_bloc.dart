import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/currency_provider.dart';
import '../../domain/entities/price_tick.dart';
import '../../domain/usecases/get_candles_usecase.dart';
import '../../domain/usecases/get_coin_detail_usecase.dart';
import '../../domain/usecases/get_price_history_usecase.dart';
import '../../domain/usecases/unsubscribe_price_updates_usecase.dart';
import '../../domain/usecases/watch_price_updates_usecase.dart';
import 'coin_detail_event.dart';
import 'coin_detail_state.dart';

class CoinDetailBloc extends Bloc<CoinDetailEvent, CoinDetailState> {
  CoinDetailBloc({
    required GetCoinDetailUseCase getCoinDetailUseCase,
    required GetPriceHistoryUseCase getPriceHistoryUseCase,
    required GetCandlesUseCase getCandlesUseCase,
    required WatchPriceUpdatesUseCase watchPriceUpdatesUseCase,
    required UnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase,
    required CurrencyProvider currencyProvider,
  })  : _getCoinDetailUseCase = getCoinDetailUseCase,
        _getPriceHistoryUseCase = getPriceHistoryUseCase,
        _getCandlesUseCase = getCandlesUseCase,
        _watchPriceUpdatesUseCase = watchPriceUpdatesUseCase,
        _unsubscribePriceUpdatesUseCase = unsubscribePriceUpdatesUseCase,
        _currencyProvider = currencyProvider,
        _subscriberId = 'coin_detail_${_instanceCounter++}',
        super(const CoinDetailState()) {
    on<CoinDetailStarted>(_onStarted);
    on<CoinDetailTimeframeChanged>(_onTimeframeChanged);
    on<CoinDetailChartTypeChanged>(_onChartTypeChanged);
    on<CoinDetailRefreshed>(_onRefreshed);
    on<CoinDetailPriceTickReceived>(_onPriceTickReceived);
  }

  static int _instanceCounter = 0;

  final GetCoinDetailUseCase _getCoinDetailUseCase;
  final GetPriceHistoryUseCase _getPriceHistoryUseCase;
  final GetCandlesUseCase _getCandlesUseCase;
  final WatchPriceUpdatesUseCase _watchPriceUpdatesUseCase;
  final UnsubscribePriceUpdatesUseCase _unsubscribePriceUpdatesUseCase;
  final CurrencyProvider _currencyProvider;
  final String _subscriberId;

  StreamSubscription<PriceTick>? _tickSubscription;
  String? _coinId;

  Future<void> _onStarted(CoinDetailStarted event, Emitter<CoinDetailState> emit) async {
    _coinId = event.coinId;
    await _loadDetailAndChart(event.coinId, state.selectedDays, emit);
  }

  Future<void> _onTimeframeChanged(
    CoinDetailTimeframeChanged event,
    Emitter<CoinDetailState> emit,
  ) async {
    if (_coinId == null) return;
    emit(state.copyWith(selectedDays: event.days, chartStatus: ChartStatus.loading));
    await _loadChart(_coinId!, event.days, emit);
  }

  Future<void> _onChartTypeChanged(
    CoinDetailChartTypeChanged event,
    Emitter<CoinDetailState> emit,
  ) async {
    if (_coinId == null) return;
    emit(state.copyWith(chartType: event.type, chartStatus: ChartStatus.loading));
    await _loadChart(_coinId!, state.selectedDays, emit);
  }

  Future<void> _onRefreshed(CoinDetailRefreshed event, Emitter<CoinDetailState> emit) async {
    if (_coinId != null) await _loadDetailAndChart(_coinId!, state.selectedDays, emit);
  }

  void _onPriceTickReceived(CoinDetailPriceTickReceived event, Emitter<CoinDetailState> emit) {
    final coin = state.coin;
    if (coin == null) return;
    // priceTicks is the shared union of every active subscriber's symbols (e.g.
    // Market's own live list), so ticks for other coins must be ignored here.
    if (event.tick.symbol != coin.symbol.toLowerCase()) return;
    emit(state.copyWith(coin: coin.withLiveTick(event.tick), isLive: true));
  }

  Future<void> _loadDetailAndChart(
    String coinId,
    int days,
    Emitter<CoinDetailState> emit,
  ) async {
    emit(state.copyWith(detailStatus: DetailStatus.loading, chartStatus: ChartStatus.loading));

    final detailResult = await _getCoinDetailUseCase(coinId);
    detailResult.fold(
      (failure) => emit(state.copyWith(detailStatus: DetailStatus.failure, detailFailure: failure)),
      (coin) {
        emit(state.copyWith(detailStatus: DetailStatus.success, coin: coin));
        _subscribeToLivePrice(coin.symbol);
      },
    );

    await _loadChart(coinId, days, emit);
  }

  Future<void> _loadChart(String coinId, int days, Emitter<CoinDetailState> emit) async {
    if (state.chartType == ChartType.candles) {
      final result = await _getCandlesUseCase(GetCandlesParams(coinId: coinId, days: days));
      result.fold(
        (failure) => emit(state.copyWith(chartStatus: ChartStatus.failure, chartFailure: failure)),
        (candles) => emit(
          state.copyWith(chartStatus: ChartStatus.success, candles: candles, chartFailure: null),
        ),
      );
      return;
    }

    final result = await _getPriceHistoryUseCase(
      GetPriceHistoryParams(coinId: coinId, days: days),
    );
    result.fold(
      (failure) => emit(state.copyWith(chartStatus: ChartStatus.failure, chartFailure: failure)),
      (points) => emit(
        state.copyWith(chartStatus: ChartStatus.success, pricePoints: points, chartFailure: null),
      ),
    );
  }

  void _subscribeToLivePrice(String symbol) {
    _tickSubscription?.cancel();
    if (_currencyProvider.currencyCode != 'usd') return;

    _tickSubscription = _watchPriceUpdatesUseCase(
      WatchPriceUpdatesParams(subscriberId: _subscriberId, symbols: [symbol]),
    ).listen((tick) => add(CoinDetailEvent.priceTickReceived(tick)));
  }

  @override
  Future<void> close() {
    _tickSubscription?.cancel();
    _unsubscribePriceUpdatesUseCase(_subscriberId);
    return super.close();
  }
}
