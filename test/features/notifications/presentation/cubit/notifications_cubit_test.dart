import 'dart:async';

import 'package:crypto_portfolio_tracker/features/notifications/domain/entities/app_notification.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/clear_notifications_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchNotificationsUseCase extends Mock implements WatchNotificationsUseCase {}

class _MockMarkNotificationReadUseCase extends Mock implements MarkNotificationReadUseCase {}

class _MockMarkAllNotificationsReadUseCase extends Mock implements MarkAllNotificationsReadUseCase {}

class _MockClearNotificationsUseCase extends Mock implements ClearNotificationsUseCase {}

AppNotification _notification(String id, {bool isRead = false}) => AppNotification(
      id: id,
      title: 'Title $id',
      body: 'Body $id',
      type: NotificationType.general,
      receivedAt: DateTime(2026, 1, 1),
      isRead: isRead,
    );

void main() {
  late _MockWatchNotificationsUseCase watchNotificationsUseCase;
  late _MockMarkNotificationReadUseCase markNotificationReadUseCase;
  late _MockMarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  late _MockClearNotificationsUseCase clearNotificationsUseCase;
  late StreamController<List<AppNotification>> controller;

  setUp(() {
    watchNotificationsUseCase = _MockWatchNotificationsUseCase();
    markNotificationReadUseCase = _MockMarkNotificationReadUseCase();
    markAllNotificationsReadUseCase = _MockMarkAllNotificationsReadUseCase();
    clearNotificationsUseCase = _MockClearNotificationsUseCase();
    controller = StreamController<List<AppNotification>>.broadcast();

    when(() => watchNotificationsUseCase()).thenAnswer((_) => controller.stream);
  });

  tearDown(() => controller.close());

  NotificationsCubit buildCubit() => NotificationsCubit(
        watchNotificationsUseCase: watchNotificationsUseCase,
        markNotificationReadUseCase: markNotificationReadUseCase,
        markAllNotificationsReadUseCase: markAllNotificationsReadUseCase,
        clearNotificationsUseCase: clearNotificationsUseCase,
      );

  test('reflects incoming notifications and computes the unread count', () async {
    final cubit = buildCubit();

    controller.add([_notification('1'), _notification('2', isRead: true)]);
    await pumpEventQueue();

    expect(cubit.state.notifications, hasLength(2));
    expect(cubit.state.unreadCount, 1);

    await cubit.close();
  });

  test('markAsRead delegates to the use case', () async {
    when(() => markNotificationReadUseCase(any())).thenAnswer((_) async {});
    final cubit = buildCubit();

    await cubit.markAsRead('1');

    verify(() => markNotificationReadUseCase('1')).called(1);

    await cubit.close();
  });

  test('markAllAsRead delegates to the use case', () async {
    when(() => markAllNotificationsReadUseCase()).thenAnswer((_) async {});
    final cubit = buildCubit();

    await cubit.markAllAsRead();

    verify(() => markAllNotificationsReadUseCase()).called(1);

    await cubit.close();
  });

  test('clearAll delegates to the use case', () async {
    when(() => clearNotificationsUseCase()).thenAnswer((_) async {});
    final cubit = buildCubit();

    await cubit.clearAll();

    verify(() => clearNotificationsUseCase()).called(1);

    await cubit.close();
  });
}
