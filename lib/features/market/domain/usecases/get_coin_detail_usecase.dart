import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/coin_detail.dart';
import '../repositories/market_repository.dart';

class GetCoinDetailUseCase implements UseCase<CoinDetail, String> {
  GetCoinDetailUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, CoinDetail>> call(String coinId) {
    return _repository.getCoinDetail(coinId);
  }
}
