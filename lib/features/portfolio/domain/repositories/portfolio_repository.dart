import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/holding.dart';

abstract class PortfolioRepository {
  /// Emits the full holdings list immediately on subscribe, then again on every change.
  Stream<List<Holding>> watchHoldings();
  Future<Either<Failure, void>> addHolding(Holding holding);
  Future<Either<Failure, void>> removeHolding(String holdingId);
}
