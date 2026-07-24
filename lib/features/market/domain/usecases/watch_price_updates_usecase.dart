import 'package:equatable/equatable.dart';

import '../entities/price_tick.dart';
import '../repositories/market_repository.dart';

/// Subscribes [subscriberId] to live ticks for [symbols] and returns the
/// shared tick stream; callers filter to the symbols they care about.
class WatchPriceUpdatesUseCase {
  WatchPriceUpdatesUseCase(this._repository);

  final MarketRepository _repository;

  Stream<PriceTick> call(WatchPriceUpdatesParams params) {
    _repository.subscribeToPriceUpdates(params.subscriberId, params.symbols);
    return _repository.priceTicks;
  }
}

class WatchPriceUpdatesParams extends Equatable {
  const WatchPriceUpdatesParams({required this.subscriberId, required this.symbols});

  final String subscriberId;
  final List<String> symbols;

  @override
  List<Object?> get props => [subscriberId, symbols];
}
