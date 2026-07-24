import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/coin.dart';
import '../entities/coin_detail.dart';
import '../entities/coin_search_result.dart';
import '../entities/price_point.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<Coin>>> getCoins({required int page, required int perPage});
  Future<Either<Failure, List<CoinSearchResult>>> searchCoins(String query);
  Future<Either<Failure, CoinDetail>> getCoinDetail(String coinId);
  Future<Either<Failure, List<PricePoint>>> getPriceHistory(String coinId, {required int days});
}
