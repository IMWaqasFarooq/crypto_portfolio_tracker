import 'package:crypto_portfolio_tracker/app.dart';
import 'package:crypto_portfolio_tracker/core/config/flavor.dart';
import 'package:crypto_portfolio_tracker/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Pumps until [finder] matches, rather than pumpAndSettle (never settles once the live pulse animates).
Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTries = 30,
  Duration step = const Duration(seconds: 1),
}) async {
  for (var i = 0; i < maxTries; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
}

/// Pumps until the given [finder] is gone from the tree, bounded like [_pumpUntilFound].
Future<void> _pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  int maxTries = 30,
  Duration step = const Duration(seconds: 1),
}) async {
  for (var i = 0; i < maxTries; i++) {
    await tester.pump(step);
    if (finder.evaluate().isEmpty) return;
  }
}

Future<void> _boot(WidgetTester tester) async {
  await configureDependencies(Flavor.development);
  registerObservabilityServices(firebaseAvailable: false);
  await tester.pumpWidget(const CryptofolioApp());
  // 'Cryptofolio' (without 'Welcome to') only appears on the splash screen.
  await _pumpUntilGone(tester, find.text('Cryptofolio'));
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
      await _pumpUntilFound(tester, find.text('Bitcoin'));

      // Log out lives on the Settings tab now, not on Home.
      // Scope to the bottom NavigationBar - the Settings page's own AppBar title
      // matches 'Settings' too once that branch has been built.
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')));
      await _pumpUntilFound(tester, find.text('Log out'));
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Welcome to Cryptofolio'), findsNothing);

      // Simulate a cold relaunch: fresh DI container + fresh widget tree.
      // The session itself lives in the platform Keychain/secure storage,
      // outside the Dart process, so it survives this reset.
      await sl.reset();
      await _boot(tester);

      expect(find.text('Welcome to Cryptofolio'), findsNothing);
      // Scope to the bottom NavigationBar - the Settings page's own AppBar title
      // matches 'Settings' too once that branch has been built.
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')));
      await _pumpUntilFound(tester, find.text('Log out'));
      expect(find.text('Log out'), findsOneWidget);

      await tester.tap(find.text('Log out'));
      await _pumpUntilFound(tester, find.text('Welcome to Cryptofolio'));

      expect(find.text('Welcome to Cryptofolio'), findsOneWidget);
      expect(find.text('Log out'), findsNothing);
    },
  );
}
