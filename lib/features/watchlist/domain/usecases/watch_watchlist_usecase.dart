import '../entities/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';

class WatchWatchlistUseCase {
  WatchWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  Stream<List<WatchlistItem>> call() => _repository.watchAll();
}
