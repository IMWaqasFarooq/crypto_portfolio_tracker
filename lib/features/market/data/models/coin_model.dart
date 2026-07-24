import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/coin.dart';

part 'coin_model.freezed.dart';
part 'coin_model.g.dart';

@freezed
abstract class CoinModel with _$CoinModel {
  const factory CoinModel({
    required String id,
    required String symbol,
    required String name,
    required String image,
    @JsonKey(name: 'current_price') required double currentPrice,
    @JsonKey(name: 'market_cap') required double marketCap,
    @JsonKey(name: 'market_cap_rank') int? marketCapRank,
    @JsonKey(name: 'price_change_percentage_24h') double? priceChangePercentage24h,
    @JsonKey(name: 'total_volume') required double totalVolume,
    @JsonKey(name: 'high_24h') double? high24h,
    @JsonKey(name: 'low_24h') double? low24h,
  }) = _CoinModel;

  factory CoinModel.fromJson(Map<String, dynamic> json) => _$CoinModelFromJson(json);
}

extension CoinModelMapper on CoinModel {
  Coin toEntity() => Coin(
        id: id,
        symbol: symbol,
        name: name,
        imageUrl: image,
        currentPrice: currentPrice,
        marketCap: marketCap,
        marketCapRank: marketCapRank,
        priceChangePercentage24h: priceChangePercentage24h ?? 0,
        totalVolume: totalVolume,
        high24h: high24h ?? currentPrice,
        low24h: low24h ?? currentPrice,
      );
}
