import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_tick.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/entities/holding.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final btcHolding = Holding(
    id: '1',
    coinId: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    imageUrl: 'https://example.com/btc.png',
    quantity: 2,
    averageBuyPrice: 100,
    purchaseDate: DateTime(2026, 1, 1),
  );

  final ethHolding = Holding(
    id: '2',
    coinId: 'ethereum',
    symbol: 'eth',
    name: 'Ethereum',
    imageUrl: 'https://example.com/eth.png',
    quantity: 4,
    averageBuyPrice: 50,
    purchaseDate: DateTime(2026, 1, 1),
  );

  test('currentPriceFor falls back to the average buy price without a live tick', () {
    final state = PortfolioState(holdings: [btcHolding]);

    expect(state.currentPriceFor(btcHolding), 100);
  });

  test('currentPriceFor uses the live tick price once one has arrived', () {
    final state = PortfolioState(
      holdings: [btcHolding],
      liveTicks: const {'btc': PriceTick(symbol: 'btc', price: 150, changePercent24h: 50)},
    );

    expect(state.currentPriceFor(btcHolding), 150);
  });

  test('valueFor, costFor and profitLossFor reflect quantity-scaled price movement', () {
    final state = PortfolioState(
      holdings: [btcHolding],
      liveTicks: const {'btc': PriceTick(symbol: 'btc', price: 150, changePercent24h: 50)},
    );

    expect(state.valueFor(btcHolding), 300);
    expect(state.costFor(btcHolding), 200);
    expect(state.profitLossFor(btcHolding), 100);
    expect(state.profitLossPercentFor(btcHolding), 50);
  });

  test('profitLossPercentFor is zero when cost is zero, avoiding division by zero', () {
    final freeHolding = Holding(
      id: '3',
      coinId: 'freecoin',
      symbol: 'free',
      name: 'FreeCoin',
      imageUrl: 'https://example.com/free.png',
      quantity: 10,
      averageBuyPrice: 0,
      purchaseDate: DateTime(2026, 1, 1),
    );
    final state = PortfolioState(holdings: [freeHolding]);

    expect(state.profitLossPercentFor(freeHolding), 0);
  });

  test('totalValue, totalCost and totalProfitLoss sum across every holding', () {
    final state = PortfolioState(
      holdings: [btcHolding, ethHolding],
      liveTicks: const {'btc': PriceTick(symbol: 'btc', price: 150, changePercent24h: 50)},
    );

    // btc: value 300, cost 200 | eth: no tick, value == cost == 200
    expect(state.totalValue, 500);
    expect(state.totalCost, 400);
    expect(state.totalProfitLoss, 100);
    expect(state.totalProfitLossPercent, 25);
  });

  test('allocationPercentFor divides a holding value by the portfolio total', () {
    final state = PortfolioState(
      holdings: [btcHolding, ethHolding],
      liveTicks: const {'btc': PriceTick(symbol: 'btc', price: 150, changePercent24h: 50)},
    );

    expect(state.allocationPercentFor(btcHolding), 60);
    expect(state.allocationPercentFor(ethHolding), 40);
  });

  test('totals are zero for an empty portfolio', () {
    const state = PortfolioState();

    expect(state.totalValue, 0);
    expect(state.totalCost, 0);
    expect(state.totalProfitLossPercent, 0);
  });
}
