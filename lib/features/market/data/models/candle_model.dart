import '../../domain/entities/candle.dart';

/// CoinGecko's `/coins/{id}/ohlc` returns `[timestampMs, open, high, low, close]` tuples.
class CandleModel {
  const CandleModel({
    required this.timestampMs,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory CandleModel.fromTuple(List<dynamic> tuple) => CandleModel(
        timestampMs: (tuple[0] as num).toInt(),
        open: (tuple[1] as num).toDouble(),
        high: (tuple[2] as num).toDouble(),
        low: (tuple[3] as num).toDouble(),
        close: (tuple[4] as num).toDouble(),
      );

  factory CandleModel.fromJson(Map<String, dynamic> json) => CandleModel(
        timestampMs: json['timestampMs'] as int,
        open: (json['open'] as num).toDouble(),
        high: (json['high'] as num).toDouble(),
        low: (json['low'] as num).toDouble(),
        close: (json['close'] as num).toDouble(),
      );

  final int timestampMs;
  final double open;
  final double high;
  final double low;
  final double close;

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
      };

  Candle toEntity() => Candle(
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
        open: open,
        high: high,
        low: low,
        close: close,
      );
}
