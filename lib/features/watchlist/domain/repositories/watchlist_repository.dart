import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/watchlist_item.dart';

abstract class WatchlistRepository {
  /// Emits the full watchlist immediately on subscribe, then again on every change.
  Stream<List<WatchlistItem>> watchAll();
  Future<Either<Failure, void>> add(WatchlistItem item);
  Future<Either<Failure, void>> remove(String coinId);
}
