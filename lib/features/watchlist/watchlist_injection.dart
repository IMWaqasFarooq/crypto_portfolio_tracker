import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/storage/hive_boxes.dart';
import '../market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import '../market/domain/usecases/watch_price_updates_usecase.dart';
import 'data/datasources/watchlist_local_datasource.dart';
import 'data/repositories/watchlist_repository_impl.dart';
import 'domain/repositories/watchlist_repository.dart';
import 'domain/usecases/add_to_watchlist_usecase.dart';
import 'domain/usecases/remove_from_watchlist_usecase.dart';
import 'domain/usecases/watch_watchlist_usecase.dart';
import 'presentation/cubit/watchlist_cubit.dart';

Future<void> registerWatchlistFeature(GetIt sl) async {
  final box = await Hive.openBox<dynamic>(HiveBoxes.watchlist);
  sl.registerSingleton<Box<dynamic>>(box, instanceName: HiveBoxes.watchlist);

  sl
    ..registerLazySingleton<WatchlistLocalDataSource>(
      () => WatchlistLocalDataSourceImpl(sl<Box<dynamic>>(instanceName: HiveBoxes.watchlist)),
    )
    ..registerLazySingleton<WatchlistRepository>(() => WatchlistRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchWatchlistUseCase(sl()))
    ..registerLazySingleton(() => AddToWatchlistUseCase(sl()))
    ..registerLazySingleton(() => RemoveFromWatchlistUseCase(sl()))
    ..registerLazySingleton(
      () => WatchlistCubit(
        watchWatchlistUseCase: sl(),
        addToWatchlistUseCase: sl(),
        removeFromWatchlistUseCase: sl(),
        watchPriceUpdatesUseCase: sl<WatchPriceUpdatesUseCase>(),
        unsubscribePriceUpdatesUseCase: sl<UnsubscribePriceUpdatesUseCase>(),
      ),
    );
}
