import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../market/domain/entities/price_tick.dart';
import '../../../market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import '../../../market/domain/usecases/watch_price_updates_usecase.dart';
import '../../domain/entities/holding.dart';
import '../../domain/usecases/add_holding_usecase.dart';
import '../../domain/usecases/remove_holding_usecase.dart';
import '../../domain/usecases/watch_holdings_usecase.dart';
import 'portfolio_state.dart';

const _subscriberId = 'portfolio';

/// App-wide singleton so every screen showing holdings/P&L observes the same data.
class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit({
    required WatchHoldingsUseCase watchHoldingsUseCase,
    required AddHoldingUseCase addHoldingUseCase,
    required RemoveHoldingUseCase removeHoldingUseCase,
    required WatchPriceUpdatesUseCase watchPriceUpdatesUseCase,
    required UnsubscribePriceUpdatesUseCase unsubscribePriceUpdatesUseCase,
  })  : _addHoldingUseCase = addHoldingUseCase,
        _removeHoldingUseCase = removeHoldingUseCase,
        _watchPriceUpdatesUseCase = watchPriceUpdatesUseCase,
        _unsubscribePriceUpdatesUseCase = unsubscribePriceUpdatesUseCase,
        super(const PortfolioState()) {
    _holdingsSubscription = watchHoldingsUseCase().listen(_onHoldingsChanged);
  }

  final AddHoldingUseCase _addHoldingUseCase;
  final RemoveHoldingUseCase _removeHoldingUseCase;
  final WatchPriceUpdatesUseCase _watchPriceUpdatesUseCase;
  final UnsubscribePriceUpdatesUseCase _unsubscribePriceUpdatesUseCase;

  late final StreamSubscription<List<Holding>> _holdingsSubscription;
  StreamSubscription<PriceTick>? _tickSubscription;

  Future<Either<Failure, void>> addHolding({
    required String coinId,
    required String symbol,
    required String name,
    required String imageUrl,
    required double quantity,
    required double averageBuyPrice,
  }) {
    return _addHoldingUseCase(
      Holding(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        coinId: coinId,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        quantity: quantity,
        averageBuyPrice: averageBuyPrice,
        purchaseDate: DateTime.now(),
      ),
    );
  }

  Future<Either<Failure, void>> removeHolding(String holdingId) =>
      _removeHoldingUseCase(holdingId);

  void _onHoldingsChanged(List<Holding> holdings) {
    emit(state.copyWith(status: PortfolioStatus.success, holdings: holdings));

    _tickSubscription?.cancel();
    if (holdings.isEmpty) return;

    final symbols = holdings.map((h) => h.symbol).toSet().toList();
    _tickSubscription = _watchPriceUpdatesUseCase(
      WatchPriceUpdatesParams(subscriberId: _subscriberId, symbols: symbols),
    ).listen((tick) {
      emit(state.copyWith(liveTicks: {...state.liveTicks, tick.symbol: tick}));
    });
  }

  @override
  Future<void> close() {
    _holdingsSubscription.cancel();
    _tickSubscription?.cancel();
    _unsubscribePriceUpdatesUseCase(_subscriberId);
    return super.close();
  }
}
