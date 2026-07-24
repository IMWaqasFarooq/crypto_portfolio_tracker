import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/watchlist_repository.dart';

class RemoveFromWatchlistUseCase implements UseCase<void, String> {
  RemoveFromWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Either<Failure, void>> call(String coinId) => _repository.remove(coinId);
}
