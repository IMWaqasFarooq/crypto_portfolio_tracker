import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_datasource.dart';
import '../models/app_notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._localDataSource);
  final NotificationsLocalDataSource _localDataSource;

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return _localDataSource.watchAll().map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> record(AppNotification notification) => _localDataSource.add(notification.toModel());

  @override
  Future<void> markAsRead(String id) => _localDataSource.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _localDataSource.markAllAsRead();

  @override
  Future<void> clearAll() => _localDataSource.clearAll();
}
