import 'package:equatable/equatable.dart';

import 'price_tick.dart';

class CoinDetail extends Equatable {
  const CoinDetail({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.homepageUrl,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.ath,
    required this.atl,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
  });

  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final String description;
  final String? homepageUrl;
  final double currentPrice;
  final double marketCap;
  final int? marketCapRank;
  final double priceChangePercentage24h;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double ath;
  final double atl;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;

  /// Applies a live [PriceTick] on top of the last REST-fetched snapshot.
  CoinDetail withLiveTick(PriceTick tick) => CoinDetail(
        id: id,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        description: description,
        homepageUrl: homepageUrl,
        currentPrice: tick.price,
        marketCap: marketCap,
        marketCapRank: marketCapRank,
        priceChangePercentage24h: tick.changePercent24h,
        totalVolume: totalVolume,
        high24h: high24h,
        low24h: low24h,
        ath: ath,
        atl: atl,
        circulatingSupply: circulatingSupply,
        totalSupply: totalSupply,
        maxSupply: maxSupply,
      );

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        imageUrl,
        description,
        homepageUrl,
        currentPrice,
        marketCap,
        marketCapRank,
        priceChangePercentage24h,
        totalVolume,
        high24h,
        low24h,
        ath,
        atl,
        circulatingSupply,
        totalSupply,
        maxSupply,
      ];
}
