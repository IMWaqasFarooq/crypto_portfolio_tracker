/// Thrown by data sources; repositories map these to [Failure] values.
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'Local cache error']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Session expired']);

  final String message;

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ParsingException implements Exception {
  const ParsingException([this.message = 'Failed to parse response']);

  final String message;

  @override
  String toString() => 'ParsingException: $message';
}
