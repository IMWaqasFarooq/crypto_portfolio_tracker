import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../market/domain/entities/price_point.dart';
import '../../../market/domain/usecases/get_price_history_usecase.dart';
import '../entities/holding.dart';

/// Approximates value over time using *current* quantities against each coin's history, not a true cost-basis ledger.
class GetPortfolioHistoryUseCase implements UseCase<List<PricePoint>, GetPortfolioHistoryParams> {
  GetPortfolioHistoryUseCase(this._getPriceHistoryUseCase);

  final GetPriceHistoryUseCase _getPriceHistoryUseCase;

  @override
  Future<Either<Failure, List<PricePoint>>> call(GetPortfolioHistoryParams params) async {
    if (params.holdings.isEmpty) return const Right([]);

    final uniqueCoinIds = params.holdings.map((h) => h.coinId).toSet();
    final historyByCoinId = <String, List<PricePoint>>{};

    for (final coinId in uniqueCoinIds) {
      final result = await _getPriceHistoryUseCase(
        GetPriceHistoryParams(coinId: coinId, days: params.days),
      );
      final failure = result.fold((f) => f, (_) => null);
      if (failure != null) return Left(failure);
      historyByCoinId[coinId] = result.fold((_) => const [], (points) => points);
    }

    final length = historyByCoinId.values.map((h) => h.length).reduce((a, b) => a < b ? a : b);
    if (length == 0) return const Right([]);

    final referenceHistory = historyByCoinId.values.first;
    final points = <PricePoint>[
      for (var i = 0; i < length; i++)
        PricePoint(
          timestamp: referenceHistory[i].timestamp,
          price: params.holdings.fold(
            0.0,
            (sum, h) => sum + historyByCoinId[h.coinId]![i].price * h.quantity,
          ),
        ),
    ];
    return Right(points);
  }
}

class GetPortfolioHistoryParams extends Equatable {
  const GetPortfolioHistoryParams({required this.holdings, required this.days});

  final List<Holding> holdings;
  final int days;

  @override
  List<Object?> get props => [holdings, days];
}
