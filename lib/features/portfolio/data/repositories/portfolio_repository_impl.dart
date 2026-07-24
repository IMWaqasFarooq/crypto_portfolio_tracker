import 'package:dartz/dartz.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/holding.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_datasource.dart';
import '../models/holding_model.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl(this._localDataSource);

  final PortfolioLocalDataSource _localDataSource;

  @override
  Stream<List<Holding>> watchHoldings() =>
      _localDataSource.watchAll().map((items) => items.map((i) => i.toEntity()).toList());

  @override
  Future<Either<Failure, void>> addHolding(Holding holding) async {
    try {
      await _localDataSource.add(holding.toModel());
      return const Right(null);
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeHolding(String holdingId) async {
    try {
      await _localDataSource.remove(holdingId);
      return const Right(null);
    } catch (e) {
      return Left(await mapExceptionToFailure(e));
    }
  }
}
