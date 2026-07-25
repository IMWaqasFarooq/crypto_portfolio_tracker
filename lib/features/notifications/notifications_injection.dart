import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import 'data/datasources/notifications_local_datasource.dart';
import 'data/repositories/notifications_repository_impl.dart';
import 'data/services/push_notification_service.dart';
import 'domain/repositories/notifications_repository.dart';
import 'domain/usecases/clear_notifications_usecase.dart';
import 'domain/usecases/mark_all_notifications_read_usecase.dart';
import 'domain/usecases/mark_notification_read_usecase.dart';
import 'domain/usecases/record_notification_usecase.dart';
import 'domain/usecases/watch_notifications_usecase.dart';
import 'presentation/cubit/notifications_cubit.dart';

const _notificationsBox = 'notifications_box';

Future<void> registerNotificationsFeature(GetIt sl) async {
  final box = await Hive.openBox<dynamic>(_notificationsBox);
  sl.registerSingleton<Box<dynamic>>(box, instanceName: _notificationsBox);

  sl
    ..registerLazySingleton<NotificationsLocalDataSource>(
      () => NotificationsLocalDataSourceImpl(sl<Box<dynamic>>(instanceName: _notificationsBox)),
    )
    ..registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchNotificationsUseCase(sl()))
    ..registerLazySingleton(() => RecordNotificationUseCase(sl()))
    ..registerLazySingleton(() => MarkNotificationReadUseCase(sl()))
    ..registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()))
    ..registerLazySingleton(() => ClearNotificationsUseCase(sl()))
    ..registerLazySingleton(() => PushNotificationService(sl(), sl<Logger>()))
    ..registerLazySingleton(
      () => NotificationsCubit(
        watchNotificationsUseCase: sl(),
        markNotificationReadUseCase: sl(),
        markAllNotificationsReadUseCase: sl(),
        clearNotificationsUseCase: sl(),
      ),
    );
}
