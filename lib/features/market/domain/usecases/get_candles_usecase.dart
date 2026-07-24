import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/candle.dart';
import '../repositories/market_repository.dart';

class GetCandlesUseCase implements UseCase<List<Candle>, GetCandlesParams> {
  GetCandlesUseCase(this._repository);

  final MarketRepository _repository;

  @override
  Future<Either<Failure, List<Candle>>> call(GetCandlesParams params) {
    return _repository.getCandles(params.coinId, days: params.days);
  }
}

class GetCandlesParams extends Equatable {
  const GetCandlesParams({required this.coinId, required this.days});

  final String coinId;
  final int days;

  @override
  List<Object?> get props => [coinId, days];
}
