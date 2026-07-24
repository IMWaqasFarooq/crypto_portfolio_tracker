import 'package:hive/hive.dart';

import '../models/watchlist_item_model.dart';

abstract class WatchlistLocalDataSource {
  /// Emits the current list on subscribe, then again on every box mutation.
  Stream<List<WatchlistItemModel>> watchAll();
  Future<void> add(WatchlistItemModel item);
  Future<void> remove(String coinId);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  WatchlistLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Stream<List<WatchlistItemModel>> watchAll() async* {
    yield _readAll();
    yield* _box.watch().map((_) => _readAll());
  }

  @override
  Future<void> add(WatchlistItemModel item) => _box.put(item.coinId, item.toJson());

  @override
  Future<void> remove(String coinId) => _box.delete(coinId);

  List<WatchlistItemModel> _readAll() {
    return _box.values
        .map((raw) => WatchlistItemModel.fromJson(Map<String, dynamic>.from(raw as Map)))
        .toList()
      ..sort((a, b) => b.addedAtMs.compareTo(a.addedAtMs));
  }
}
