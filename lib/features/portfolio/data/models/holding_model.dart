import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/holding.dart';

part 'holding_model.freezed.dart';
part 'holding_model.g.dart';

@freezed
abstract class HoldingModel with _$HoldingModel {
  const factory HoldingModel({
    required String id,
    required String coinId,
    required String symbol,
    required String name,
    required String imageUrl,
    required double quantity,
    required double averageBuyPrice,
    required int purchaseDateMs,
  }) = _HoldingModel;

  factory HoldingModel.fromJson(Map<String, dynamic> json) => _$HoldingModelFromJson(json);
}

extension HoldingModelMapper on HoldingModel {
  Holding toEntity() => Holding(
        id: id,
        coinId: coinId,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        quantity: quantity,
        averageBuyPrice: averageBuyPrice,
        purchaseDate: DateTime.fromMillisecondsSinceEpoch(purchaseDateMs),
      );
}

extension HoldingEntityMapper on Holding {
  HoldingModel toModel() => HoldingModel(
        id: id,
        coinId: coinId,
        symbol: symbol,
        name: name,
        imageUrl: imageUrl,
        quantity: quantity,
        averageBuyPrice: averageBuyPrice,
        purchaseDateMs: purchaseDate.millisecondsSinceEpoch,
      );
}
