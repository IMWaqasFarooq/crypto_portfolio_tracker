import 'package:equatable/equatable.dart';

import 'price_tick.dart';

class Coin extends Equatable {
  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
  });

  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketCap;
  final int? marketCapRank;
  final double priceChangePercentage24h;
  final double totalVolume;
  final double high24h;
  final double low24h;

  /// Applies a live [PriceTick] on top of the last REST-fetched snapshot.
  Coin withLiveTick(PriceTick tick) => Coin(
        id: id,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        currentPrice: tick.price,
        marketCap: marketCap,
        marketCapRank: marketCapRank,
        priceChangePercentage24h: tick.changePercent24h,
        totalVolume: totalVolume,
        high24h: high24h,
        low24h: low24h,
      );

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        imageUrl,
        currentPrice,
        marketCap,
        marketCapRank,
        priceChangePercentage24h,
        totalVolume,
        high24h,
        low24h,
      ];
}
