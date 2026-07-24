import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin_detail_event.freezed.dart';

@freezed
sealed class CoinDetailEvent with _$CoinDetailEvent {
  const factory CoinDetailEvent.started(String coinId) = CoinDetailStarted;
  const factory CoinDetailEvent.timeframeChanged(int days) = CoinDetailTimeframeChanged;
  const factory CoinDetailEvent.refreshed() = CoinDetailRefreshed;
}
