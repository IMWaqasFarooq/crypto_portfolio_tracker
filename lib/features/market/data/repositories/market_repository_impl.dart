import 'package:dartz/dartz.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/coin.dart';
import '../../domain/entities/coin_detail.dart';
import '../../domain/entities/coin_search_result.dart';
import '../../domain/entities/price_point.dart';
import '../../domain/entities/price_tick.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_local_datasource.dart';
import '../datasources/market_remote_datasource.dart';
import '../datasources/market_stream_datasource.dart';
import '../models/coin_model.dart';
import '../models/coin_search_result_model.dart';

class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.streamDataSource,
    required this.networkInfo,
  });

  final MarketRemoteDataSource remoteDataSource;
  final MarketLocalDataSource localDataSource;
  final MarketStreamDataSource streamDataSource;
  final NetworkInfo networkInfo;

  @override
  Stream<PriceTick> get priceTicks => streamDataSource.priceTicks.map((t) => t.toEntity());

  @override
  void subscribeToPriceUpdates(String subscriberId, List<String> symbols) =>
      streamDataSource.subscribe(subscriberId, symbols);

  @override
  void unsubscribeFromPriceUpdates(String subscriberId) =>
      streamDataSource.unsubscribe(subscriberId);

  @override
  Future<Either<Failure, List<Coin>>> getCoins({required int page, required int perPage}) async {
    if (await networkInfo.isConnected) {
      try {
        final coins = await remoteDataSource.getCoins(page: page, perPage: perPage);
        await localDataSource.cacheCoins(page, coins);
        return Right(coins.map((c) => c.toEntity()).toList());
      } catch (e) {
        final cached = await localDataSource.getCachedCoins(page);
        if (cached != null) return Right(cached.map((c) => c.toEntity()).toList());
        return Left(await mapExceptionToFailure(e));
      }
    }

    final cached = await localDataSource.getCachedCoins(page);
    if (cached != null) return Right(cached.map((c) => c.toEntity()).toList());
    return const Left(Failure.network(message: 'No internet connection and no cached data'));
  }

  @override
  Future<Either<Failure, List<CoinSearchResult>>> searchCoins(String query) async {
    if (query.trim().isEmpty) return const Right([]);
    try {
      final results = await remoteDataSource.searchCoins(query.trim());
      return Right(results.map((r) => r.toEntity()).toList());
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, CoinDetail>> getCoinDetail(String coinId) async {
    try {
      final detail = await remoteDataSource.getCoinDetail(coinId);
      return Right(detail.toEntity());
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<PricePoint>>> getPriceHistory(
    String coinId, {
    required int days,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final points = await remoteDataSource.getPriceHistory(coinId, days: days);
        await localDataSource.cachePriceHistory(coinId, days, points);
        return Right(points.map((p) => p.toEntity()).toList());
      } catch (e) {
        final cached = await localDataSource.getCachedPriceHistory(coinId, days);
        if (cached != null) return Right(cached.map((p) => p.toEntity()).toList());
        return Left(await mapExceptionToFailure(e));
      }
    }

    final cached = await localDataSource.getCachedPriceHistory(coinId, days);
    if (cached != null) return Right(cached.map((p) => p.toEntity()).toList());
    return const Left(Failure.network(message: 'No internet connection and no cached data'));
  }

  @override
  Future<Either<Failure, List<Candle>>> getCandles(String coinId, {required int days}) async {
    if (await networkInfo.isConnected) {
      try {
        final candles = await remoteDataSource.getCandles(coinId, days: days);
        await localDataSource.cacheCandles(coinId, days, candles);
        return Right(candles.map((c) => c.toEntity()).toList());
      } catch (e) {
        final cached = await localDataSource.getCachedCandles(coinId, days);
        if (cached != null) return Right(cached.map((c) => c.toEntity()).toList());
        return Left(await mapExceptionToFailure(e));
      }
    }

    final cached = await localDataSource.getCachedCandles(coinId, days);
    if (cached != null) return Right(cached.map((c) => c.toEntity()).toList());
    return const Left(Failure.network(message: 'No internet connection and no cached data'));
  }
}
