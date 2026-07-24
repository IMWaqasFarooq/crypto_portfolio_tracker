import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/price_tick.dart';

part 'market_event.freezed.dart';

@freezed
sealed class MarketEvent with _$MarketEvent {
  const factory MarketEvent.started() = MarketStarted;
  const factory MarketEvent.refreshed() = MarketRefreshed;
  const factory MarketEvent.loadMoreRequested() = MarketLoadMoreRequested;
  const factory MarketEvent.priceTickReceived(PriceTick tick) = MarketPriceTickReceived;
}
