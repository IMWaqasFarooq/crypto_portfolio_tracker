import '../repositories/notifications_repository.dart';

class ClearNotificationsUseCase {
  ClearNotificationsUseCase(this._repository);
  final NotificationsRepository _repository;

  Future<void> call() => _repository.clearAll();
}
