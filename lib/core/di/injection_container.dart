import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../config/env_config.dart';
import '../config/flavor.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/network_info.dart';
import '../services/analytics_service.dart';
import '../services/crash_reporting_service.dart';
import '../services/firebase_analytics_service.dart';
import '../services/firebase_crash_reporting_service.dart';
import '../storage/token_storage.dart';

import '../../features/authentication/auth_injection.dart';

/// Root service locator; each feature registers into this same container.
final sl = GetIt.instance;

/// Boots the DI graph for the given [flavor]. Must be awaited before `runApp`.
Future<void> configureDependencies(Flavor flavor) async {
  await _registerCore(flavor);
  registerAuthFeature(sl);
}

/// Falls back to no-op services when Firebase isn't configured yet.
void registerObservabilityServices({required bool firebaseAvailable}) {
  if (firebaseAvailable) {
    sl
      ..registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics.instance)
      ..registerLazySingleton<FirebaseCrashlytics>(() => FirebaseCrashlytics.instance)
      ..registerLazySingleton<AnalyticsService>(() => FirebaseAnalyticsService(sl()))
      ..registerLazySingleton<CrashReportingService>(() => FirebaseCrashReportingService(sl()));
  } else {
    sl
      ..registerLazySingleton<AnalyticsService>(() => const NoOpAnalyticsService())
      ..registerLazySingleton<CrashReportingService>(() => const NoOpCrashReportingService());
  }
}

Future<void> _registerCore(Flavor flavor) async {
  final env = EnvConfig(flavor);
  await env.load();
  sl.registerSingleton<EnvConfig>(env);
  sl.registerSingleton<Flavor>(flavor);

  await Hive.initFlutter();

  sl
    ..registerLazySingleton<Logger>(
      () => Logger(printer: PrettyPrinter(methodCount: 0, colors: !flavor.isProduction)),
    )
    ..registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage())
    ..registerLazySingleton<TokenStorage>(() => SecureTokenStorage(sl()))
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(sl()))
    ..registerLazySingleton<Dio>(
      () => DioClient.create(
        env: sl(),
        authInterceptor: sl(),
        networkInfo: sl(),
      ),
    );
}
