import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Verbose request/response logging; only attached when enableNetworkLogging is true.
class LoggingInterceptor extends PrettyDioLogger {
  LoggingInterceptor()
      : super(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        );
}
