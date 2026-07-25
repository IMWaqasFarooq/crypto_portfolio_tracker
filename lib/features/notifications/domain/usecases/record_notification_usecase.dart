import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class RecordNotificationUseCase {
  RecordNotificationUseCase(this._repository);
  final NotificationsRepository _repository;

  Future<void> call(AppNotification notification) => _repository.record(notification);
}
