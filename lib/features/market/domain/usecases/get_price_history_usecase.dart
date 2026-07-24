import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/price_point.dart';
import '../repositories/market_repository.dart';

class GetPriceHistoryUseCase implements UseCase<List<PricePoint>, GetPriceHistoryParams> {
  GetPriceHistoryUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<PricePoint>>> call(GetPriceHistoryParams params) {
    return _repository.getPriceHistory(params.coinId, days: params.days);
  }
}

class GetPriceHistoryParams extends Equatable {
  const GetPriceHistoryParams({required this.coinId, required this.days});

  final String coinId;
  final int days;

  @override
  List<Object?> get props => [coinId, days];
}
