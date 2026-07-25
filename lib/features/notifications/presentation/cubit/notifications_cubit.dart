import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/clear_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/watch_notifications_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required WatchNotificationsUseCase watchNotificationsUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
    required MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase,
    required ClearNotificationsUseCase clearNotificationsUseCase,
  })  : _markNotificationReadUseCase = markNotificationReadUseCase,
        _markAllNotificationsReadUseCase = markAllNotificationsReadUseCase,
        _clearNotificationsUseCase = clearNotificationsUseCase,
        super(const NotificationsState()) {
    _subscription = watchNotificationsUseCase().listen(
      (notifications) => emit(state.copyWith(notifications: notifications)),
    );
  }

  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final ClearNotificationsUseCase _clearNotificationsUseCase;
  late final StreamSubscription<List<AppNotification>> _subscription;

  Future<void> markAsRead(String id) => _markNotificationReadUseCase(id);

  Future<void> markAllAsRead() => _markAllNotificationsReadUseCase();

  Future<void> clearAll() => _clearNotificationsUseCase();

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
