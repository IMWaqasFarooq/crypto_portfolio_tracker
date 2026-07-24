import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/portfolio_repository.dart';

class RemoveHoldingUseCase implements UseCase<void, String> {
  RemoveHoldingUseCase(this._repository);

  final PortfolioRepository _repository;

  @override
  Future<Either<Failure, void>> call(String holdingId) => _repository.removeHolding(holdingId);
}
