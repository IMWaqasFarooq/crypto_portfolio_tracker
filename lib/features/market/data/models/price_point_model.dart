import '../../domain/entities/price_point.dart';

/// CoinGecko returns `prices` as `[[timestampMs, price], ...]` pairs, not objects.
class PricePointModel {
  const PricePointModel({required this.timestampMs, required this.price});

  factory PricePointModel.fromPair(List<dynamic> pair) => PricePointModel(
        timestampMs: (pair[0] as num).toInt(),
        price: (pair[1] as num).toDouble(),
      );

  factory PricePointModel.fromJson(Map<String, dynamic> json) => PricePointModel(
        timestampMs: json['timestampMs'] as int,
        price: (json['price'] as num).toDouble(),
      );

  final int timestampMs;
  final double price;

  Map<String, dynamic> toJson() => {'timestampMs': timestampMs, 'price': price};

  PricePoint toEntity() => PricePoint(
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
        price: price,
      );
}
