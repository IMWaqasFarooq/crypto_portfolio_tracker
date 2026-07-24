import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/candle_model.dart';
import '../models/coin_model.dart';
import '../models/price_point_model.dart';

abstract class MarketLocalDataSource {
  Future<void> cacheCoins(int page, List<CoinModel> coins);
  Future<List<CoinModel>?> getCachedCoins(int page);
  Future<void> cachePriceHistory(String coinId, int days, List<PricePointModel> points);
  Future<List<PricePointModel>?> getCachedPriceHistory(String coinId, int days);
  Future<void> cacheCandles(String coinId, int days, List<CandleModel> candles);
  Future<List<CandleModel>?> getCachedCandles(String coinId, int days);
}

/// Caches raw JSON (not typed Hive adapters) in the market box - avoids
/// hand-maintaining TypeAdapters for models that already round-trip through
/// json_serializable, at the cost of a decode step on cache reads.
class MarketLocalDataSourceImpl implements MarketLocalDataSource {
  MarketLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<void> cacheCoins(int page, List<CoinModel> coins) async {
    await _write('coins_page_$page', coins.map((c) => c.toJson()).toList());
  }

  @override
  Future<List<CoinModel>?> getCachedCoins(int page) async {
    final raw = _read('coins_page_$page');
    if (raw == null) return null;
    return raw
        .cast<Map<dynamic, dynamic>>()
        .map((m) => CoinModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<void> cachePriceHistory(String coinId, int days, List<PricePointModel> points) async {
    await _write('price_history_${coinId}_$days', points.map((p) => p.toJson()).toList());
  }

  @override
  Future<List<PricePointModel>?> getCachedPriceHistory(String coinId, int days) async {
    final raw = _read('price_history_${coinId}_$days');
    if (raw == null) return null;
    return raw
        .cast<Map<dynamic, dynamic>>()
        .map((m) => PricePointModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<void> cacheCandles(String coinId, int days, List<CandleModel> candles) async {
    await _write('candles_${coinId}_$days', candles.map((c) => c.toJson()).toList());
  }

  @override
  Future<List<CandleModel>?> getCachedCandles(String coinId, int days) async {
    final raw = _read('candles_${coinId}_$days');
    if (raw == null) return null;
    return raw
        .cast<Map<dynamic, dynamic>>()
        .map((m) => CandleModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> _write(String key, List<Map<String, dynamic>> data) async {
    try {
      await _box.put(key, {
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      });
    } catch (_) {
      throw const CacheException('Failed to write cache');
    }
  }

  List<dynamic>? _read(String key) {
    final entry = _box.get(key);
    if (entry == null) return null;
    final map = Map<String, dynamic>.from(entry as Map);
    return map['data'] as List<dynamic>;
  }
}
