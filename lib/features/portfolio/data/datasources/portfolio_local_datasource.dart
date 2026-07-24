import 'package:hive/hive.dart';

import '../models/holding_model.dart';

abstract class PortfolioLocalDataSource {
  /// Emits the current list on subscribe, then again on every box mutation.
  Stream<List<HoldingModel>> watchAll();
  Future<void> add(HoldingModel holding);
  Future<void> remove(String holdingId);
}

class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  PortfolioLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Stream<List<HoldingModel>> watchAll() async* {
    yield _readAll();
    yield* _box.watch().map((_) => _readAll());
  }

  @override
  Future<void> add(HoldingModel holding) => _box.put(holding.id, holding.toJson());

  @override
  Future<void> remove(String holdingId) => _box.delete(holdingId);

  List<HoldingModel> _readAll() {
    return _box.values
        .map((raw) => HoldingModel.fromJson(Map<String, dynamic>.from(raw as Map)))
        .toList()
      ..sort((a, b) => b.purchaseDateMs.compareTo(a.purchaseDateMs));
  }
}
