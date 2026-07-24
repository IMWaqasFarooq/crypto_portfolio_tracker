import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../market/domain/entities/price_tick.dart';
import '../../domain/entities/watchlist_item.dart';

part 'watchlist_state.freezed.dart';

enum WatchlistStatus { loading, success }

@freezed
abstract class WatchlistState with _$WatchlistState {
  const WatchlistState._();

  const factory WatchlistState({
    @Default(WatchlistStatus.loading) WatchlistStatus status,
    @Default(<WatchlistItem>[]) List<WatchlistItem> items,
    @Default(<String, PriceTick>{}) Map<String, PriceTick> liveTicks,
  }) = _WatchlistState;

  bool isWatched(String coinId) => items.any((i) => i.coinId == coinId);
}
