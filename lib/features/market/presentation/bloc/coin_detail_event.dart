import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/price_tick.dart';
import 'coin_detail_state.dart';

part 'coin_detail_event.freezed.dart';

@freezed
sealed class CoinDetailEvent with _$CoinDetailEvent {
  const factory CoinDetailEvent.started(String coinId) = CoinDetailStarted;
  const factory CoinDetailEvent.timeframeChanged(int days) = CoinDetailTimeframeChanged;
  const factory CoinDetailEvent.chartTypeChanged(ChartType type) = CoinDetailChartTypeChanged;
  const factory CoinDetailEvent.refreshed() = CoinDetailRefreshed;
  const factory CoinDetailEvent.priceTickReceived(PriceTick tick) = CoinDetailPriceTickReceived;
}
