import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

class NotificationsState extends Equatable {
  const NotificationsState({this.notifications = const []});
  final List<AppNotification> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({List<AppNotification>? notifications}) =>
      NotificationsState(notifications: notifications ?? this.notifications);

  @override
  List<Object?> get props => [notifications];
}
