import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Stream<List<AppNotification>> watchNotifications();
  Future<void> record(AppNotification notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> clearAll();
}
