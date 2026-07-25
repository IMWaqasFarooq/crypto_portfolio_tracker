import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late _MockWatchlistRepository repository;
  late RemoveFromWatchlistUseCase useCase;

  setUp(() {
    repository = _MockWatchlistRepository();
    useCase = RemoveFromWatchlistUseCase(repository);
  });

  test('delegates the coin id to the repository', () async {
    when(() => repository.remove(any())).thenAnswer((_) async => const Right(null));

    final result = await useCase('bitcoin');

    expect(result, const Right<Failure, void>(null));
    verify(() => repository.remove('bitcoin')).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.remove(any())).thenAnswer((_) async => const Left(Failure.cache()));

    final result = await useCase('bitcoin');

    expect(result, const Left<Failure, void>(Failure.cache()));
  });
}
