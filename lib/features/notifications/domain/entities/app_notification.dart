import 'package:equatable/equatable.dart';

enum NotificationType { priceAlert, marketNews, general }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.receivedAt,
    required this.isRead,
    this.coinId,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime receivedAt;
  final bool isRead;
  final String? coinId;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        receivedAt: receivedAt,
        isRead: isRead ?? this.isRead,
        coinId: coinId,
      );

  @override
  List<Object?> get props => [id, title, body, type, receivedAt, isRead, coinId];
}
