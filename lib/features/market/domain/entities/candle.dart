import 'package:equatable/equatable.dart';

class Candle extends Equatable {
  const Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;

  @override
  List<Object?> get props => [timestamp, open, high, low, close];
}
