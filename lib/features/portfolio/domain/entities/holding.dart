import 'package:equatable/equatable.dart';

class Holding extends Equatable {
  const Holding({
    required this.id,
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.averageBuyPrice,
    required this.purchaseDate,
  });

  final String id;
  final String coinId;
  final String symbol;
  final String name;
  final String imageUrl;
  final double quantity;
  final double averageBuyPrice;
  final DateTime purchaseDate;

  @override
  List<Object?> get props =>
      [id, coinId, symbol, name, imageUrl, quantity, averageBuyPrice, purchaseDate];
}
