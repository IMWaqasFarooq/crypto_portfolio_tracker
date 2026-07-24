import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';
import '../models/coin_search_result_model.dart';
import '../models/price_point_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<CoinModel>> getCoins({required int page, required int perPage});
  Future<List<CoinSearchResultModel>> searchCoins(String query);
  Future<CoinDetailModel> getCoinDetail(String coinId);
  Future<List<PricePointModel>> getPriceHistory(String coinId, {required int days});
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  MarketRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CoinModel>> getCoins({required int page, required int perPage}) async {
    final response = await _get('/coins/markets', queryParameters: {
      'vs_currency': 'usd',
      'order': 'market_cap_desc',
      'page': page,
      'per_page': perPage,
      'sparkline': false,
      'price_change_percentage': '24h',
    });
    final data = response.data as List<dynamic>;
    return data.map((e) => CoinModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CoinSearchResultModel>> searchCoins(String query) async {
    final response = await _get('/search', queryParameters: {'query': query});
    final coins = (response.data as Map<String, dynamic>)['coins'] as List<dynamic>;
    return coins.map((e) => CoinSearchResultModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    final response = await _get('/coins/$coinId', queryParameters: {
      'localization': false,
      'tickers': false,
      'community_data': false,
      'developer_data': false,
      'sparkline': false,
    });
    return CoinDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<PricePointModel>> getPriceHistory(String coinId, {required int days}) async {
    final response = await _get('/coins/$coinId/market_chart', queryParameters: {
      'vs_currency': 'usd',
      'days': days,
    });
    final prices = (response.data as Map<String, dynamic>)['prices'] as List<dynamic>;
    return prices.map((e) => PricePointModel.fromPair(e as List<dynamic>)).toList();
  }

  Future<Response<dynamic>> _get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': false}),
      );
    } on DioException catch (e) {
      final mapped = e.error;
      if (mapped is Exception) throw mapped;
      throw ServerException(message: e.message ?? 'Failed to reach CoinGecko');
    }
  }
}
