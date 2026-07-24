import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../market/domain/entities/price_tick.dart';
import '../../domain/entities/holding.dart';

part 'portfolio_state.freezed.dart';

enum PortfolioStatus { loading, success }

@freezed
abstract class PortfolioState with _$PortfolioState {
  const PortfolioState._();

  const factory PortfolioState({
    @Default(PortfolioStatus.loading) PortfolioStatus status,
    @Default(<Holding>[]) List<Holding> holdings,
    @Default(<String, PriceTick>{}) Map<String, PriceTick> liveTicks,
  }) = _PortfolioState;

  double currentPriceFor(Holding h) => liveTicks[h.symbol.toLowerCase()]?.price ?? h.averageBuyPrice;

  double valueFor(Holding h) => currentPriceFor(h) * h.quantity;

  double costFor(Holding h) => h.averageBuyPrice * h.quantity;

  double profitLossFor(Holding h) => valueFor(h) - costFor(h);

  double profitLossPercentFor(Holding h) {
    final cost = costFor(h);
    return cost == 0 ? 0 : (profitLossFor(h) / cost) * 100;
  }

  double allocationPercentFor(Holding h) => totalValue == 0 ? 0 : (valueFor(h) / totalValue) * 100;

  double get totalValue => holdings.fold(0.0, (sum, h) => sum + valueFor(h));

  double get totalCost => holdings.fold(0.0, (sum, h) => sum + costFor(h));

  double get totalProfitLoss => totalValue - totalCost;

  double get totalProfitLossPercent => totalCost == 0 ? 0 : (totalProfitLoss / totalCost) * 100;
}
