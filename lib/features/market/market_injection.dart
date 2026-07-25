import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/storage/hive_boxes.dart';
import 'data/datasources/market_local_datasource.dart';
import 'data/datasources/market_remote_datasource.dart';
import 'data/datasources/market_stream_datasource.dart';
import 'data/repositories/market_repository_impl.dart';
import 'domain/repositories/market_repository.dart';
import 'domain/usecases/get_candles_usecase.dart';
import 'domain/usecases/get_coin_detail_usecase.dart';
import 'domain/usecases/get_coins_usecase.dart';
import 'domain/usecases/get_price_history_usecase.dart';
import 'domain/usecases/search_coins_usecase.dart';
import 'domain/usecases/unsubscribe_price_updates_usecase.dart';
import 'domain/usecases/watch_price_updates_usecase.dart';
import 'presentation/bloc/coin_detail_bloc.dart';
import 'presentation/bloc/coin_search_cubit.dart';
import 'presentation/bloc/market_bloc.dart';

Future<void> registerMarketFeature(GetIt sl) async {
  final box = await Hive.openBox<dynamic>(HiveBoxes.market);
  sl.registerSingleton<Box<dynamic>>(box, instanceName: HiveBoxes.market);

  sl
    ..registerLazySingleton<MarketRemoteDataSource>(() => MarketRemoteDataSourceImpl(sl(), sl()))
    ..registerLazySingleton<MarketLocalDataSource>(
      () => MarketLocalDataSourceImpl(sl<Box<dynamic>>(instanceName: HiveBoxes.market), sl()),
    )
    ..registerLazySingleton<MarketStreamDataSource>(() => BinanceMarketStreamDataSource())
    ..registerLazySingleton<MarketRepository>(
      () => MarketRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        streamDataSource: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton(() => GetCoinsUseCase(sl()))
    ..registerLazySingleton(() => SearchCoinsUseCase(sl()))
    ..registerLazySingleton(() => GetCoinDetailUseCase(sl()))
    ..registerLazySingleton(() => GetPriceHistoryUseCase(sl()))
    ..registerLazySingleton(() => GetCandlesUseCase(sl()))
    ..registerLazySingleton(() => WatchPriceUpdatesUseCase(sl()))
    ..registerLazySingleton(() => UnsubscribePriceUpdatesUseCase(sl()))
    ..registerFactory(
      () => MarketBloc(
        getCoinsUseCase: sl(),
        watchPriceUpdatesUseCase: sl(),
        unsubscribePriceUpdatesUseCase: sl(),
        currencyProvider: sl(),
      ),
    )
    ..registerFactory(() => CoinSearchCubit(searchCoinsUseCase: sl()))
    ..registerFactory(
      () => CoinDetailBloc(
        getCoinDetailUseCase: sl(),
        getPriceHistoryUseCase: sl(),
        getCandlesUseCase: sl(),
        watchPriceUpdatesUseCase: sl(),
        unsubscribePriceUpdatesUseCase: sl(),
        currencyProvider: sl(),
      ),
    );
}
