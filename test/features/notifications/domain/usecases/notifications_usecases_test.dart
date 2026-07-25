import 'package:crypto_portfolio_tracker/features/notifications/domain/entities/app_notification.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/clear_notifications_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/record_notification_usecase.dart';
import 'package:crypto_portfolio_tracker/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  late _MockNotificationsRepository repository;

  final notification = AppNotification(
    id: '1',
    title: 'BTC is up 5%',
    body: r'Bitcoin crossed $70,000',
    type: NotificationType.priceAlert,
    receivedAt: DateTime(2026, 1, 1),
    isRead: false,
    coinId: 'bitcoin',
  );

  setUpAll(() => registerFallbackValue(notification));

  setUp(() {
    repository = _MockNotificationsRepository();
  });

  test('WatchNotificationsUseCase delegates to the repository stream', () {
    when(() => repository.watchNotifications()).thenAnswer((_) => Stream.value([notification]));

    final stream = WatchNotificationsUseCase(repository)();

    expect(stream, emits([notification]));
  });

  test('RecordNotificationUseCase delegates the notification to the repository', () async {
    when(() => repository.record(any())).thenAnswer((_) async {});

    await RecordNotificationUseCase(repository)(notification);

    verify(() => repository.record(notification)).called(1);
  });

  test('MarkNotificationReadUseCase delegates the id to the repository', () async {
    when(() => repository.markAsRead(any())).thenAnswer((_) async {});

    await MarkNotificationReadUseCase(repository)('1');

    verify(() => repository.markAsRead('1')).called(1);
  });

  test('MarkAllNotificationsReadUseCase delegates to the repository', () async {
    when(() => repository.markAllAsRead()).thenAnswer((_) async {});

    await MarkAllNotificationsReadUseCase(repository)();

    verify(() => repository.markAllAsRead()).called(1);
  });

  test('ClearNotificationsUseCase delegates to the repository', () async {
    when(() => repository.clearAll()).thenAnswer((_) async {});

    await ClearNotificationsUseCase(repository)();

    verify(() => repository.clearAll()).called(1);
  });
}
