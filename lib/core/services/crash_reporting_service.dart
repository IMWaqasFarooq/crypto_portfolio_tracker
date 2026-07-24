/// Abstraction over crash/error reporting.
abstract class CrashReportingService {
  Future<void> recordError(Object error, StackTrace? stackTrace, {bool fatal = false});
  Future<void> log(String message);
  Future<void> setUserId(String? userId);
}
