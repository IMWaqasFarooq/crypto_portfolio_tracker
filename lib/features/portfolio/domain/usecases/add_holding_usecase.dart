import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/holding.dart';
import '../repositories/portfolio_repository.dart';

class AddHoldingUseCase implements UseCase<void, Holding> {
  AddHoldingUseCase(this._repository);

  final PortfolioRepository _repository;

  @override
  Future<Either<Failure, void>> call(Holding params) => _repository.addHolding(params);
}
