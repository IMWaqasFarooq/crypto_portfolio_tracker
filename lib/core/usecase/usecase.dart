import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contract every domain use case implements.
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Contract for use cases that stream continuous updates.
abstract class StreamUseCase<Result, Params> {
  Stream<Either<Failure, Result>> call(Params params);
}

/// Marker params object for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
