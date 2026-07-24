import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../market/domain/entities/price_tick.dart';
import '../../../market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import '../../../market/domain/usecases/watch_price_updates_usecase.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/usecases/add_to_watchlist_usecase.dart';
import '../../domain/usecases/remove_from_watchlist_usecase.dart';
import '../../domain/usecases/watch_watchlist_usecase.dart';
import 'watchlist_state.dart';

const _subscriberId = 'watchlist';

/// App-wide singleton so every screen observes the same watched set.
class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit({
    required WatchWatchlistUseCase watchWatchlistUseCase,
    required AddToWatchlistUseCase addToWatchlistUseCase,
    required RemoveFromWatchlistUseCase removeFromWatchlistUseCase,
    required WatchPriceUpdatesUseCase watchPriceUpdatesUseCase,
    required UnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase,
  })  : _addToWatchlistUseCase = addToWatchlistUseCase,
        _removeFromWatchlistUseCase = removeFromWatchlistUseCase,
        _watchPriceUpdatesUseCase = watchPriceUpdatesUseCase,
        _unsubscribePriceUpdatesUseCase = unsubscribePriceUpdatesUseCase,
        super(const WatchlistState()) {
    _itemsSubscription = watchWatchlistUseCase().listen(_onItemsChanged);
  }

  final AddToWatchlistUseCase _addToWatchlistUseCase;
  final RemoveFromWatchlistUseCase _removeFromWatchlistUseCase;
  final WatchPriceUpdatesUseCase _watchPriceUpdatesUseCase;
  final UnsubscribePriceUpdatesUseCase _unsubscribePriceUpdatesUseCase;

  late final StreamSubscription<List<WatchlistItem>> _itemsSubscription;
  StreamSubscription<PriceTick>? _tickSubscription;

  Future<void> toggle(WatchlistItem item) {
    return state.isWatched(item.coinId)
        ? _removeFromWatchlistUseCase(item.coinId)
        : _addToWatchlistUseCase(item);
  }

  void _onItemsChanged(List<WatchlistItem> items) {
    emit(state.copyWith(status: WatchlistStatus.success, items: items));

    _tickSubscription?.cancel();
    if (items.isEmpty) return;

    final symbols = items.map((i) => i.symbol).toList();
    _tickSubscription = _watchPriceUpdatesUseCase(
      WatchPriceUpdatesParams(subscriberId: _subscriberId, symbols: symbols),
    ).listen((tick) {
      emit(state.copyWith(liveTicks: {...state.liveTicks, tick.symbol: tick}));
    });
  }

  @override
  Future<void> close() {
    _itemsSubscription.cancel();
    _tickSubscription?.cancel();
    _unsubscribePriceUpdatesUseCase(_subscriberId);
    return super.close();
  }
}
