import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/storage/hive_boxes.dart';
import '../market/domain/usecases/get_price_history_usecase.dart';
import '../market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import '../market/domain/usecases/watch_price_updates_usecase.dart';
import 'data/datasources/portfolio_local_datasource.dart';
import 'data/repositories/portfolio_repository_impl.dart';
import 'domain/repositories/portfolio_repository.dart';
import 'domain/usecases/add_holding_usecase.dart';
import 'domain/usecases/get_portfolio_history_usecase.dart';
import 'domain/usecases/remove_holding_usecase.dart';
import 'domain/usecases/watch_holdings_usecase.dart';
import 'presentation/cubit/portfolio_cubit.dart';
import 'presentation/cubit/portfolio_history_cubit.dart';

Future<void> registerPortfolioFeature(GetIt sl) async {
  final box = await Hive.openBox<dynamic>(HiveBoxes.portfolio);
  sl.registerSingleton<Box<dynamic>>(box, instanceName: HiveBoxes.portfolio);

  sl
    ..registerLazySingleton<PortfolioLocalDataSource>(
      () => PortfolioLocalDataSourceImpl(sl<Box<dynamic>>(instanceName: HiveBoxes.portfolio)),
    )
    ..registerLazySingleton<PortfolioRepository>(() => PortfolioRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchHoldingsUseCase(sl()))
    ..registerLazySingleton(() => AddHoldingUseCase(sl()))
    ..registerLazySingleton(() => RemoveHoldingUseCase(sl()))
    ..registerLazySingleton(() => GetPortfolioHistoryUseCase(sl<GetPriceHistoryUseCase>()))
    ..registerLazySingleton(
      () => PortfolioCubit(
        watchHoldingsUseCase: sl(),
        addHoldingUseCase: sl(),
        removeHoldingUseCase: sl(),
        watchPriceUpdatesUseCase: sl<WatchPriceUpdatesUseCase>(),
        unsubscribePriceUpdatesUseCase: sl<UnsubscribePriceUpdatesUseCase>(),
      ),
    )
    ..registerFactory(() => PortfolioHistoryCubit(getPortfolioHistoryUseCase: sl()));
}
