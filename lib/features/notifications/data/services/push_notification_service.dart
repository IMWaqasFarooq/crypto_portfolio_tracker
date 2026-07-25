import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import '../../../../firebase_options.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/record_notification_usecase.dart';

const _androidChannel = AndroidNotificationChannel(
  'price_alerts',
  'Price Alerts',
  description: 'Live price movement and market alerts',
  importance: Importance.high,
);

/// Runs in a background isolate with no DI graph; the OS already displays
/// the system notification for background/terminated pushes, so this only
/// re-initializes Firebase to satisfy the plugin's isolate contract.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService {
  PushNotificationService(this._recordNotificationUseCase, this._logger);

  final RecordNotificationUseCase _recordNotificationUseCase;
  final Logger _logger;
  final _localPlugin = FlutterLocalNotificationsPlugin();
  int _idCounter = 0;

  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    await _localPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(requestAlertPermission: false),
      ),
    );
    if (Platform.isAndroid) {
      await _localPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleForegroundMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) await _handleForegroundMessage(initialMessage);

    final token = await FirebaseMessaging.instance.getToken();
    _logger.i('FCM token: $token');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Cryptofolio';
    final body = message.notification?.body ?? '';

    await _localPlugin.show(
      id: _idCounter++,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name),
        iOS: const DarwinNotificationDetails(),
      ),
    );

    await _recordNotificationUseCase(
      AppNotification(
        id: message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        body: body,
        type: _typeFromData(message.data),
        receivedAt: DateTime.now(),
        isRead: false,
        coinId: message.data['coinId'] as String?,
      ),
    );
  }

  NotificationType _typeFromData(Map<String, dynamic> data) {
    return switch (data['type']) {
      'price_alert' => NotificationType.priceAlert,
      'market_news' => NotificationType.marketNews,
      _ => NotificationType.general,
    };
  }
}
