import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late _MockWatchlistRepository repository;
  late AddToWatchlistUseCase useCase;

  final item = WatchlistItem(
    coinId: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    imageUrl: 'https://example.com/btc.png',
    addedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() => registerFallbackValue(item));

  setUp(() {
    repository = _MockWatchlistRepository();
    useCase = AddToWatchlistUseCase(repository);
  });

  test('delegates the item to the repository', () async {
    when(() => repository.add(any())).thenAnswer((_) async => const Right(null));

    final result = await useCase(item);

    expect(result, const Right<Failure, void>(null));
    verify(() => repository.add(item)).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(() => repository.add(any())).thenAnswer((_) async => const Left(Failure.cache()));

    final result = await useCase(item);

    expect(result, const Left<Failure, void>(Failure.cache()));
  });
}
