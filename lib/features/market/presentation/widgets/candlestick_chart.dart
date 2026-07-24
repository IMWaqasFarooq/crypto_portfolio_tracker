import 'package:candlesticks/candlesticks.dart' as pkg;
import 'package:flutter/material.dart';

import '../../domain/entities/candle.dart';

class CandlestickChart extends StatelessWidget {
  const CandlestickChart({super.key, required this.candles});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    if (candles.length < 2) {
      return const SizedBox(height: 300, child: Center(child: Text('Not enough data')));
    }

    // The package expects newest-first; our candles arrive oldest-first.
    final packageCandles = candles.reversed
        .map(
          (c) => pkg.Candle(
            date: c.timestamp,
            open: c.open,
            high: c.high,
            low: c.low,
            close: c.close,
            volume: 0,
          ),
        )
        .toList();

    return SizedBox(
      height: 300,
      child: pkg.Candlesticks(candles: packageCandles),
    );
  }
}
