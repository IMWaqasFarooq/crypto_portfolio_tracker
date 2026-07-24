import '../../domain/entities/coin_detail.dart';

/// Hand-parsed since CoinGecko nests fields under market_data/description/links.
class CoinDetailModel {
  const CoinDetailModel({
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

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    final marketData = (json['market_data'] as Map<String, dynamic>?) ?? const {};
    final description = (json['description'] as Map<String, dynamic>?) ?? const {};
    final links = (json['links'] as Map<String, dynamic>?) ?? const {};
    final homepages = (links['homepage'] as List<dynamic>?) ?? const [];
    final image = (json['image'] as Map<String, dynamic>?) ?? const {};

    double usd(String key) => _asDouble(_currencyMap(marketData, key)?['usd']) ?? 0;

    return CoinDetailModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      imageUrl: (image['large'] ?? image['small'] ?? image['thumb'] ?? '') as String,
      description: (description['en'] as String?) ?? '',
      homepageUrl: homepages.isNotEmpty ? homepages.first as String? : null,
      currentPrice: usd('current_price'),
      marketCap: usd('market_cap'),
      marketCapRank: json['market_cap_rank'] as int?,
      priceChangePercentage24h: _asDouble(marketData['price_change_percentage_24h']) ?? 0,
      totalVolume: usd('total_volume'),
      high24h: usd('high_24h'),
      low24h: usd('low_24h'),
      ath: usd('ath'),
      atl: usd('atl'),
      circulatingSupply: _asDouble(marketData['circulating_supply']),
      totalSupply: _asDouble(marketData['total_supply']),
      maxSupply: _asDouble(marketData['max_supply']),
    );
  }

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

  CoinDetail toEntity() => CoinDetail(
        id: id,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        description: description,
        homepageUrl: homepageUrl,
        currentPrice: currentPrice,
        marketCap: marketCap,
        marketCapRank: marketCapRank,
        priceChangePercentage24h: priceChangePercentage24h,
        totalVolume: totalVolume,
        high24h: high24h,
        low24h: low24h,
        ath: ath,
        atl: atl,
        circulatingSupply: circulatingSupply,
        totalSupply: totalSupply,
        maxSupply: maxSupply,
      );
}

Map<String, dynamic>? _currencyMap(Map<String, dynamic> marketData, String key) =>
    marketData[key] as Map<String, dynamic>?;

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
