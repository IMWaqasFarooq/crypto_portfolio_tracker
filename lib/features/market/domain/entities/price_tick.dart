import 'package:equatable/equatable.dart';

/// A live price update pushed over the market data stream.
class PriceTick extends Equatable {
  const PriceTick({required this.symbol, required this.price, required this.changePercent24h});

  /// Lowercase coin symbol, e.g. `btc`.
  final String symbol;
  final double price;
  final double changePercent24h;

  @override
  List<Object?> get props => [symbol, price, changePercent24h];
}
