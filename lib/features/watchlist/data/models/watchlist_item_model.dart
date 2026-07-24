import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/watchlist_item.dart';

part 'watchlist_item_model.freezed.dart';
part 'watchlist_item_model.g.dart';

@freezed
abstract class WatchlistItemModel with _$WatchlistItemModel {
  const factory WatchlistItemModel({
    required String coinId,
    required String symbol,
    required String name,
    required String imageUrl,
    required int addedAtMs,
  }) = _WatchlistItemModel;

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) =>
      _$WatchlistItemModelFromJson(json);
}

extension WatchlistItemModelMapper on WatchlistItemModel {
  WatchlistItem toEntity() => WatchlistItem(
        coinId: coinId,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        addedAt: DateTime.fromMillisecondsSinceEpoch(addedAtMs),
      );
}

extension WatchlistItemEntityMapper on WatchlistItem {
  WatchlistItemModel toModel() => WatchlistItemModel(
        coinId: coinId,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        addedAtMs: addedAt.millisecondsSinceEpoch,
      );
}
