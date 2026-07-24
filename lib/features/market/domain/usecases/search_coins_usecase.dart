import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/coin_search_result.dart';
import '../repositories/market_repository.dart';

class SearchCoinsUseCase implements UseCase<List<CoinSearchResult>, String> {
  SearchCoinsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<CoinSearchResult>>> call(String query) {
    return _repository.searchCoins(query);
  }
}
