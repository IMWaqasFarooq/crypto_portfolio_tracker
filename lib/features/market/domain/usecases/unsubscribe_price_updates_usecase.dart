import '../repositories/market_repository.dart';

class UnsubscribePriceUpdatesUseCase {
  UnsubscribePriceUpdatesUseCase(this._repository);

  final MarketRepository _repository;

  void call(String subscriberId) => _repository.unsubscribeFromPriceUpdates(subscriberId);
}
