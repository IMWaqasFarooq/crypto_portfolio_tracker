import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_coin_detail_usecase.dart';
import '../../domain/usecases/get_price_history_usecase.dart';
import 'coin_detail_event.dart';
import 'coin_detail_state.dart';

class CoinDetailBloc extends Bloc<CoinDetailEvent, CoinDetailState> {
  CoinDetailBloc({
    required GetCoinDetailUseCase getCoinDetailUseCase,
    required GetPriceHistoryUseCase getPriceHistoryUseCase,
  })  : _getCoinDetailUseCase = getCoinDetailUseCase,
        _getPriceHistoryUseCase = getPriceHistoryUseCase,
        super(const CoinDetailState()) {
    on<CoinDetailStarted>(_onStarted);
    on<CoinDetailTimeframeChanged>(_onTimeframeChanged);
    on<CoinDetailRefreshed>(_onRefreshed);
  }

  final GetCoinDetailUseCase _getCoinDetailUseCase;
  final GetPriceHistoryUseCase _getPriceHistoryUseCase;

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

  Future<void> _onRefreshed(CoinDetailRefreshed event, Emitter<CoinDetailState> emit) async {
    if (_coinId != null) await _loadDetailAndChart(_coinId!, state.selectedDays, emit);
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
      (coin) => emit(state.copyWith(detailStatus: DetailStatus.success, coin: coin)),
    );

    await _loadChart(coinId, days, emit);
  }

  Future<void> _loadChart(String coinId, int days, Emitter<CoinDetailState> emit) async {
    final chartResult = await _getPriceHistoryUseCase(
      GetPriceHistoryParams(coinId: coinId, days: days),
    );
    chartResult.fold(
      (failure) => emit(state.copyWith(chartStatus: ChartStatus.failure, chartFailure: failure)),
      (points) => emit(
        state.copyWith(chartStatus: ChartStatus.success, pricePoints: points, chartFailure: null),
      ),
    );
  }
}
