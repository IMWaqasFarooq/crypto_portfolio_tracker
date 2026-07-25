import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../core/services/currency_provider.dart';
import '../../core/storage/hive_boxes.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/update_settings_usecase.dart';
import 'domain/usecases/watch_settings_usecase.dart';
import 'presentation/cubit/settings_cubit.dart';

Future<void> registerSettingsFeature(GetIt sl) async {
  sl
    ..registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(
        sl<Box<dynamic>>(instanceName: HiveBoxes.settings),
        sl<CurrencyProvider>(),
      ),
    )
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchSettingsUseCase(sl()))
    ..registerLazySingleton(() => UpdateSettingsUseCase(sl()))
    ..registerLazySingleton(
      () => SettingsCubit(watchSettingsUseCase: sl(), updateSettingsUseCase: sl()),
    );
}
