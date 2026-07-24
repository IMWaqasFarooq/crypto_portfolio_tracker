import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/coin.dart';

part 'market_state.freezed.dart';

enum MarketStatus { initial, loading, success, failure }

@freezed
abstract class MarketState with _$MarketState {
  const factory MarketState({
    @Default(MarketStatus.initial) MarketStatus status,
    @Default(<Coin>[]) List<Coin> coins,
    @Default(1) int currentPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,
    Failure? failure,
    @Default(<String>{}) Set<String> liveSymbols,
  }) = _MarketState;
}
