import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'crash_reporting_service.dart';

class FirebaseCrashReportingService implements CrashReportingService {
  FirebaseCrashReportingService(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(Object error, StackTrace? stackTrace, {bool fatal = false}) {
    return _crashlytics.recordError(error, stackTrace, fatal: fatal);
  }

  @override
  Future<void> log(String message) async => _crashlytics.log(message);

  @override
  Future<void> setUserId(String? userId) => _crashlytics.setUserIdentifier(userId ?? '');
}

class NoOpCrashReportingService implements CrashReportingService {
  const NoOpCrashReportingService();

  @override
  Future<void> recordError(Object error, StackTrace? stackTrace, {bool fatal = false}) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
