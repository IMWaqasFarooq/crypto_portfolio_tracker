import 'package:dartz/dartz.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';
import '../models/watchlist_item_model.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl(this._localDataSource);

  final WatchlistLocalDataSource _localDataSource;

  @override
  Stream<List<WatchlistItem>> watchAll() =>
      _localDataSource.watchAll().map((items) => items.map((i) => i.toEntity()).toList());

  @override
  Future<Either<Failure, void>> add(WatchlistItem item) async {
    try {
      await _localDataSource.add(item.toModel());
      return const Right(null);
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String coinId) async {
    try {
      await _localDataSource.remove(coinId);
      return const Right(null);
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }
}
