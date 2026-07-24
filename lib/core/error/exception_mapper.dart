import 'dart:async';
import 'dart:io';

import 'exceptions.dart';
import 'failures.dart';

/// Converts a caught exception into the matching [Failure].
Future<Failure> mapExceptionToFailure(Object error) async {
  return switch (error) {
    ServerException e => Failure.server(message: e.message, statusCode: e.statusCode),
    NetworkException e => Failure.network(message: e.message),
    CacheException e => Failure.cache(message: e.message),
    UnauthorizedException e => Failure.unauthorized(message: e.message),
    ParsingException e => Failure.unknown(message: e.message),
    SocketException _ => const Failure.network(),
    TimeoutException _ => const Failure.network(message: 'Request timed out'),
    _ => Failure.unknown(message: error.toString()),
  };
}
