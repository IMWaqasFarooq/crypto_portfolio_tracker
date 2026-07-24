/// Abstraction over analytics event tracking, so callers never depend on firebase_analytics directly.
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> logScreenView(String screenName);
  Future<void> setUserId(String? userId);
}
