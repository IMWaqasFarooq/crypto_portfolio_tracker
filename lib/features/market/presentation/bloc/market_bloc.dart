import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_coins_usecase.dart';
import 'market_event.dart';
import 'market_state.dart';

const _perPage = 25;

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc({required GetCoinsUseCase getCoinsUseCase})
      : _getCoinsUseCase = getCoinsUseCase,
        super(const MarketState()) {
    on<MarketStarted>(_onStarted);
    on<MarketRefreshed>(_onRefreshed);
    on<MarketLoadMoreRequested>(_onLoadMoreRequested);
  }

  final GetCoinsUseCase _getCoinsUseCase;

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
      (coins) => emit(
        state.copyWith(
          status: MarketStatus.success,
          coins: append ? [...state.coins, ...coins] : coins,
          currentPage: page,
          hasMore: coins.length >= _perPage,
          isLoadingMore: false,
          failure: null,
        ),
      ),
    );
  }
}
