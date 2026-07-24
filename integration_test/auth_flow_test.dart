import 'package:crypto_portfolio_tracker/app.dart';
import 'package:crypto_portfolio_tracker/core/config/flavor.dart';
import 'package:crypto_portfolio_tracker/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _boot(WidgetTester tester) async {
  await configureDependencies(Flavor.development);
  registerObservabilityServices(firebaseAvailable: false);
  await tester.pumpWidget(const CryptofolioApp());
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'login shows home, relaunch auto-logs-in via persisted session, logout returns to login',
    (tester) async {
      await sl.reset();
      await _boot(tester);

      expect(find.text('Welcome to Cryptofolio'), findsOneWidget);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'demo@cryptofolio.dev');
      await tester.enterText(fields.at(1), 'password123');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Welcome to Cryptofolio'), findsNothing);

      // Simulate a cold relaunch: fresh DI container + fresh widget tree.
      // The session itself lives in the platform Keychain/secure storage,
      // outside the Dart process, so it survives this reset.
      await sl.reset();
      await _boot(tester);

      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Welcome to Cryptofolio'), findsNothing);

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Welcome to Cryptofolio'), findsOneWidget);
      expect(find.text('Log out'), findsNothing);
    },
  );
}
