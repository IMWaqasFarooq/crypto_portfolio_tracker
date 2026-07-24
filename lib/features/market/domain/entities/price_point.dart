import 'package:equatable/equatable.dart';

class PricePoint extends Equatable {
  const PricePoint({required this.timestamp, required this.price});

  final DateTime timestamp;
  final double price;

  @override
  List<Object?> get props => [timestamp, price];
}
