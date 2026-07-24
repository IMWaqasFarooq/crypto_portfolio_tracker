import 'package:equatable/equatable.dart';

class WatchlistItem extends Equatable {
  const WatchlistItem({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.addedAt,
  });

  final String coinId;
  final String symbol;
  final String name;
  final String imageUrl;
  final DateTime addedAt;

  @override
  List<Object?> get props => [coinId, symbol, name, imageUrl, addedAt];
}
