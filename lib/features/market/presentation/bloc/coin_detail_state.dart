import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/coin_detail.dart';
import '../../domain/entities/price_point.dart';

part 'coin_detail_state.freezed.dart';

enum DetailStatus { initial, loading, success, failure }

enum ChartStatus { initial, loading, success, failure }

enum ChartType { line, candles }

@freezed
abstract class CoinDetailState with _$CoinDetailState {
  const factory CoinDetailState({
    @Default(DetailStatus.initial) DetailStatus detailStatus,
    CoinDetail? coin,
    Failure? detailFailure,
    @Default(false) bool isLive,
    @Default(ChartStatus.initial) ChartStatus chartStatus,
    @Default(ChartType.line) ChartType chartType,
    @Default(<PricePoint>[]) List<PricePoint> pricePoints,
    @Default(<Candle>[]) List<Candle> candles,
    Failure? chartFailure,
    @Default(1) int selectedDays,
  }) = _CoinDetailState;
}
