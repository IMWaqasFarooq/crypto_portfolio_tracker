import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/coin.dart';
import '../repositories/market_repository.dart';

class GetCoinsUseCase implements UseCase<List<Coin>, GetCoinsParams> {
  GetCoinsUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<Coin>>> call(GetCoinsParams params) {
    return _repository.getCoins(page: params.page, perPage: params.perPage);
  }
}

class GetCoinsParams extends Equatable {
  const GetCoinsParams({required this.page, this.perPage = 25});

  final int page;
  final int perPage;

  @override
  List<Object?> get props => [page, perPage];
}
