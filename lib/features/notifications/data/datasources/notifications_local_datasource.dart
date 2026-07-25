import 'package:hive/hive.dart';

import '../models/app_notification_model.dart';

abstract class NotificationsLocalDataSource {
  Stream<List<AppNotificationModel>> watchAll();
  Future<void> add(AppNotificationModel notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> clearAll();
}

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  NotificationsLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Stream<List<AppNotificationModel>> watchAll() async* {
    yield _readAll();
    yield* _box.watch().map((_) => _readAll());
  }

  @override
  Future<void> add(AppNotificationModel notification) => _box.put(notification.id, notification.toJson());

  @override
  Future<void> markAsRead(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final model = AppNotificationModel.fromJson(Map<String, dynamic>.from(raw as Map));
    await _box.put(id, model.copyWith(isRead: true).toJson());
  }

  @override
  Future<void> markAllAsRead() async {
    for (final model in _readAll()) {
      await _box.put(model.id, model.copyWith(isRead: true).toJson());
    }
  }

  @override
  Future<void> clearAll() => _box.clear();

  List<AppNotificationModel> _readAll() {
    return _box.values
        .map((raw) => AppNotificationModel.fromJson(Map<String, dynamic>.from(raw as Map)))
        .toList()
      ..sort((a, b) => b.receivedAtMs.compareTo(a.receivedAtMs));
  }
}
