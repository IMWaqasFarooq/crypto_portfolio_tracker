import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// The error type every repository returns via `Either<Failure, T>`.
@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.network({
    @Default('No internet connection') String message,
  }) = NetworkFailure;

  const factory Failure.cache({
    @Default('Local cache error') String message,
  }) = CacheFailure;

  const factory Failure.unauthorized({
    @Default('Session expired') String message,
  }) = UnauthorizedFailure;

  const factory Failure.validation({
    required String message,
  }) = ValidationFailure;

  const factory Failure.unknown({
    @Default('Something went wrong') String message,
  }) = UnknownFailure;
}
