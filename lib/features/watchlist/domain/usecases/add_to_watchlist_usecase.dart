import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';

class AddToWatchlistUseCase implements UseCase<void, WatchlistItem> {
  AddToWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Either<Failure, void>> call(WatchlistItem params) => _repository.add(params);
}
