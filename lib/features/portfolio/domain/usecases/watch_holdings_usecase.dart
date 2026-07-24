import '../entities/holding.dart';
import '../repositories/portfolio_repository.dart';

class WatchHoldingsUseCase {
  WatchHoldingsUseCase(this._repository);

  final PortfolioRepository _repository;

  Stream<List<Holding>> call() => _repository.watchHoldings();
}
