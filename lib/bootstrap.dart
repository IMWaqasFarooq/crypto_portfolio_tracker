import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/flavor.dart';
import 'core/di/injection_container.dart';
import 'firebase_options.dart';

/// Shared entrypoint for every flavor: DI, Firebase (best-effort), uncaught-error capture.
Future<void> bootstrap(Flavor flavor) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await configureDependencies(flavor);

      final firebaseAvailable = await _tryInitializeFirebase();
      registerObservabilityServices(firebaseAvailable: firebaseAvailable);

      if (firebaseAvailable) {
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      }

      runApp(const CryptofolioApp());
    },
    (error, stackTrace) {
      if (sl.isRegistered<FirebaseCrashlytics>()) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      } else {
        debugPrint('Uncaught error (Crashlytics unavailable): $error\n$stackTrace');
      }
    },
  );
}

Future<bool> _tryInitializeFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return true;
  } catch (e) {
    debugPrint('Firebase.initializeApp() failed, using no-op services: $e');
    return false;
  }
}
