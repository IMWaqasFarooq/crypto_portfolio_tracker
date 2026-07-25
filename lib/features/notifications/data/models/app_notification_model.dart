import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_notification.dart';

part 'app_notification_model.freezed.dart';
part 'app_notification_model.g.dart';

@freezed
abstract class AppNotificationModel with _$AppNotificationModel {
  const factory AppNotificationModel({
    required String id,
    required String title,
    required String body,
    required String type,
    required int receivedAtMs,
    required bool isRead,
    String? coinId,
  }) = _AppNotificationModel;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationModelFromJson(json);
}

extension AppNotificationModelMapper on AppNotificationModel {
  AppNotification toEntity() => AppNotification(
        id: id,
        title: title,
        body: body,
        type: NotificationType.values.firstWhere(
          (t) => t.name == type,
          orElse: () => NotificationType.general,
        ),
        receivedAt: DateTime.fromMillisecondsSinceEpoch(receivedAtMs),
        isRead: isRead,
        coinId: coinId,
      );
}

extension AppNotificationEntityMapper on AppNotification {
  AppNotificationModel toModel() => AppNotificationModel(
        id: id,
        title: title,
        body: body,
        type: type.name,
        receivedAtMs: receivedAt.millisecondsSinceEpoch,
        isRead: isRead,
        coinId: coinId,
      );
}
