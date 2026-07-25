import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/currency_provider.dart';
import '../../domain/entities/coin.dart';
import '../../domain/entities/price_tick.dart';
import '../../domain/usecases/get_coins_usecase.dart';
import '../../domain/usecases/unsubscribe_price_updates_usecase.dart';
import '../../domain/usecases/watch_price_updates_usecase.dart';
import 'market_event.dart';
import 'market_state.dart';

const _perPage = 25;

/// Caps live-subscribed symbols so pagination can't grow the stream URL unbounded.
const _maxLiveSymbols = 30;

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc({
    required GetCoinsUseCase getCoinsUseCase,
    required WatchPriceUpdatesUseCase watchPriceUpdatesUseCase,
    required UnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase,
    required CurrencyProvider currencyProvider,
  })  : _getCoinsUseCase = getCoinsUseCase,
        _watchPriceUpdatesUseCase = watchPriceUpdatesUseCase,
        _unsubscribePriceUpdatesUseCase = unsubscribePriceUpdatesUseCase,
        _currencyProvider = currencyProvider,
        _subscriberId = 'market_list_${_instanceCounter++}',
        super(const MarketState()) {
    on<MarketStarted>(_onStarted);
    on<MarketRefreshed>(_onRefreshed);
    on<MarketLoadMoreRequested>(_onLoadMoreRequested);
    on<MarketPriceTickReceived>(_onPriceTickReceived);
    _currencySubscription = currencyProvider.watch().skip(1).listen(
          (_) => add(const MarketEvent.refreshed()),
        );
  }

  static int _instanceCounter = 0;

  final GetCoinsUseCase _getCoinsUseCase;
  final WatchPriceUpdatesUseCase _watchPriceUpdatesUseCase;
  final UnsubscribePriceUpdatesUseCase _unsubscribePriceUpdatesUseCase;
  final CurrencyProvider _currencyProvider;
  final String _subscriberId;

  StreamSubscription<PriceTick>? _tickSubscription;
  late final StreamSubscription<String> _currencySubscription;

  Future<void> _onStarted(MarketStarted event, Emitter<MarketState> emit) async {
    emit(state.copyWith(status: MarketStatus.loading));
    await _loadPage(page: 1, emit: emit);
  }

  Future<void> _onRefreshed(MarketRefreshed event, Emitter<MarketState> emit) async {
    await _loadPage(page: 1, emit: emit);
  }

  Future<void> _onLoadMoreRequested(
    MarketLoadMoreRequested event,
    Emitter<MarketState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.status != MarketStatus.success) return;
    emit(state.copyWith(isLoadingMore: true));
    await _loadPage(page: state.currentPage + 1, emit: emit, append: true);
  }

  void _onPriceTickReceived(MarketPriceTickReceived event, Emitter<MarketState> emit) {
    final tick = event.tick;
    final index = state.coins.indexWhere((c) => c.symbol.toLowerCase() == tick.symbol);
    if (index == -1) return;

    final updatedCoins = [...state.coins];
    updatedCoins[index] = updatedCoins[index].withLiveTick(tick);

    emit(state.copyWith(coins: updatedCoins, liveSymbols: {...state.liveSymbols, tick.symbol}));
  }

  Future<void> _loadPage({
    required int page,
    required Emitter<MarketState> emit,
    bool append = false,
  }) async {
    final result = await _getCoinsUseCase(GetCoinsParams(page: page, perPage: _perPage));
    result.fold(
      (failure) => emit(
        state.copyWith(status: MarketStatus.failure, failure: failure, isLoadingMore: false),
      ),
      (coins) {
        final allCoins = append ? [...state.coins, ...coins] : coins;
        emit(
          state.copyWith(
            status: MarketStatus.success,
            coins: allCoins,
            currentPage: page,
            hasMore: coins.length >= _perPage,
            isLoadingMore: false,
            failure: null,
          ),
        );
        _resubscribeToLivePrices(allCoins);
      },
    );
  }

  void _resubscribeToLivePrices(List<Coin> coins) {
    _tickSubscription?.cancel();
    // Binance streams are USD(T)-denominated; only live-tick when displaying
    // USD, otherwise prices would silently drift from the selected currency.
    if (_currencyProvider.currencyCode != 'usd') return;

    final symbols = coins.take(_maxLiveSymbols).map((c) => c.symbol).toList();
    _tickSubscription = _watchPriceUpdatesUseCase(
      WatchPriceUpdatesParams(subscriberId: _subscriberId, symbols: symbols),
    ).listen((tick) => add(MarketEvent.priceTickReceived(tick)));
  }

  @override
  Future<void> close() {
    _tickSubscription?.cancel();
    _currencySubscription.cancel();
    _unsubscribePriceUpdatesUseCase(_subscriberId);
    return super.close();
  }
}
