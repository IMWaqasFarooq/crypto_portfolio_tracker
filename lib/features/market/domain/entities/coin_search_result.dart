import 'package:equatable/equatable.dart';

class CoinSearchResult extends Equatable {
  const CoinSearchResult({
    required this.id,
    required this.symbol,
    required this.name,
    required this.thumbnailUrl,
    required this.marketCapRank,
  });

  final String id;
  final String symbol;
  final String name;
  final String thumbnailUrl;
  final int? marketCapRank;

  @override
  List<Object?> get props => [id, symbol, name, thumbnailUrl, marketCapRank];
}
