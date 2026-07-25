import 'dart:async';

import 'package:crypto_portfolio_tracker/features/market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/watch_price_updates_usecase.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/domain/usecases/watch_watchlist_usecase.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_portfolio_tracker/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchWatchlistUseCase extends Mock implements WatchWatchlistUseCase {}

class _MockAddToWatchlistUseCase extends Mock implements AddToWatchlistUseCase {}

class _MockRemoveFromWatchlistUseCase extends Mock implements RemoveFromWatchlistUseCase {}

class _MockWatchPriceUpdatesUseCase extends Mock implements WatchPriceUpdatesUseCase {}

class _MockUnsubscribePriceUpdatesUseCase extends Mock implements UnsubscribePriceUpdatesUseCase {}

WatchlistItem _item(String coinId) => WatchlistItem(
      coinId: coinId,
      symbol: coinId,
      name: coinId,
      imageUrl: 'https://example.com/$coinId.png',
      addedAt: DateTime(2026, 1, 1),
    );

void main() {
  late _MockWatchWatchlistUseCase watchWatchlistUseCase;
  late _MockAddToWatchlistUseCase addToWatchlistUseCase;
  late _MockRemoveFromWatchlistUseCase removeFromWatchlistUseCase;
  late _MockWatchPriceUpdatesUseCase watchPriceUpdatesUseCase;
  late _MockUnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase;
  late StreamController<List<WatchlistItem>> itemsController;

  setUpAll(() {
    registerFallbackValue(const WatchPriceUpdatesParams(subscriberId: '', symbols: []));
    registerFallbackValue(_item('bitcoin'));
  });

  setUp(() {
    watchWatchlistUseCase = _MockWatchWatchlistUseCase();
    addToWatchlistUseCase = _MockAddToWatchlistUseCase();
    removeFromWatchlistUseCase = _MockRemoveFromWatchlistUseCase();
    watchPriceUpdatesUseCase = _MockWatchPriceUpdatesUseCase();
    unsubscribePriceUpdatesUseCase = _MockUnsubscribePriceUpdatesUseCase();
    itemsController = StreamController<List<WatchlistItem>>.broadcast();

    when(() => watchWatchlistUseCase()).thenAnswer((_) => itemsController.stream);
    when(() => watchPriceUpdatesUseCase(any())).thenAnswer((_) => const Stream.empty());
    when(() => unsubscribePriceUpdatesUseCase(any())).thenReturn(null);
  });

  tearDown(() => itemsController.close());

  WatchlistCubit buildCubit() => WatchlistCubit(
        watchWatchlistUseCase: watchWatchlistUseCase,
        addToWatchlistUseCase: addToWatchlistUseCase,
        removeFromWatchlistUseCase: removeFromWatchlistUseCase,
        watchPriceUpdatesUseCase: watchPriceUpdatesUseCase,
        unsubscribePriceUpdatesUseCase: unsubscribePriceUpdatesUseCase,
      );

  test('emits success with the watchlist and subscribes to live ticks', () async {
    final cubit = buildCubit();
    final items = [_item('bitcoin')];

    itemsController.add(items);
    await pumpEventQueue();

    expect(cubit.state, WatchlistState(status: WatchlistStatus.success, items: items));
    verify(() => watchPriceUpdatesUseCase(
          const WatchPriceUpdatesParams(subscriberId: 'watchlist', symbols: ['bitcoin']),
        )).called(1);

    await cubit.close();
  });

  test('toggle adds a coin that is not yet watched', () async {
    when(() => addToWatchlistUseCase(any())).thenAnswer((_) async => const Right(null));
    final cubit = buildCubit();

    await cubit.toggle(_item('bitcoin'));

    verify(() => addToWatchlistUseCase(any())).called(1);
    verifyNever(() => removeFromWatchlistUseCase(any()));

    await cubit.close();
  });

  test('toggle removes a coin that is already watched', () async {
    when(() => removeFromWatchlistUseCase(any())).thenAnswer((_) async => const Right(null));
    final cubit = buildCubit();

    itemsController.add([_item('bitcoin')]);
    await pumpEventQueue();

    await cubit.toggle(_item('bitcoin'));

    verify(() => removeFromWatchlistUseCase('bitcoin')).called(1);
    verifyNever(() => addToWatchlistUseCase(any()));

    await cubit.close();
  });

  test('isWatched reflects the current items list', () async {
    final cubit = buildCubit();

    itemsController.add([_item('bitcoin')]);
    await pumpEventQueue();

    expect(cubit.state.isWatched('bitcoin'), isTrue);
    expect(cubit.state.isWatched('ethereum'), isFalse);

    await cubit.close();
  });
}
