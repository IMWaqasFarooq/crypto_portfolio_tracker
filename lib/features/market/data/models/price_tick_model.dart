import '../../domain/entities/price_tick.dart';

/// Hand-parsed from a Binance 24hr ticker payload (`s`/`c`/`P` fields).
class PriceTickModel {
  const PriceTickModel({required this.symbol, required this.price, required this.changePercent24h});

  factory PriceTickModel.fromBinanceTicker(Map<String, dynamic> json) {
    final fullSymbol = (json['s'] as String).toLowerCase();
    final baseSymbol = fullSymbol.endsWith('usdt')
        ? fullSymbol.substring(0, fullSymbol.length - 4)
        : fullSymbol;
    return PriceTickModel(
      symbol: baseSymbol,
      price: double.parse(json['c'] as String),
      changePercent24h: double.parse(json['P'] as String),
    );
  }

  final String symbol;
  final double price;
  final double changePercent24h;

  PriceTick toEntity() => PriceTick(symbol: symbol, price: price, changePercent24h: changePercent24h);
}
