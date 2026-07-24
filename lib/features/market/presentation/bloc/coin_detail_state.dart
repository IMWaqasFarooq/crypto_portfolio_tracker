import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/coin_detail.dart';
import '../../domain/entities/price_point.dart';

part 'coin_detail_state.freezed.dart';

enum DetailStatus { initial, loading, success, failure }

enum ChartStatus { initial, loading, success, failure }

@freezed
abstract class CoinDetailState with _$CoinDetailState {
  const factory CoinDetailState({
    @Default(DetailStatus.initial) DetailStatus detailStatus,
    CoinDetail? coin,
    Failure? detailFailure,
    @Default(ChartStatus.initial) ChartStatus chartStatus,
    @Default(<PricePoint>[]) List<PricePoint> pricePoints,
    Failure? chartFailure,
    @Default(1) int selectedDays,
  }) = _CoinDetailState;
}
