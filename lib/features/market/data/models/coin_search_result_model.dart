import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/coin_search_result.dart';

part 'coin_search_result_model.freezed.dart';
part 'coin_search_result_model.g.dart';

@freezed
abstract class CoinSearchResultModel with _$CoinSearchResultModel {
  const factory CoinSearchResultModel({
    required String id,
    required String symbol,
    required String name,
    required String thumb,
    @JsonKey(name: 'market_cap_rank') int? marketCapRank,
  }) = _CoinSearchResultModel;

  factory CoinSearchResultModel.fromJson(Map<String, dynamic> json) =>
      _$CoinSearchResultModelFromJson(json);
}

extension CoinSearchResultModelMapper on CoinSearchResultModel {
  CoinSearchResult toEntity() => CoinSearchResult(
        id: id,
        symbol: symbol,
        name: name,
        thumbnailUrl: thumb,
        marketCapRank: marketCapRank,
      );
}
