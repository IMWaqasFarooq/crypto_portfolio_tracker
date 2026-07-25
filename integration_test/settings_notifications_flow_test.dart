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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'switch theme, currency and notification toggles, then open the notifications inbox',
    (tester) async {
      await sl.reset();
      await configureDependencies(Flavor.development);
      registerObservabilityServices(firebaseAvailable: false);
      await tester.pumpWidget(const CryptofolioApp());
      await _pumpUntilFound(tester, find.text('Sign in'));

      if (find.text('Sign in').evaluate().isNotEmpty) {
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'demo@cryptofolio.dev');
        await tester.enterText(fields.at(1), 'password123');
        await tester.tap(find.text('Sign in'));
        await _pumpUntilFound(tester, find.text('Market'));
      }
      await _pumpUntilFound(tester, find.text('Bitcoin'));

      // --- Open Settings ---
      await tester.tap(find.text('Settings'));
      await _pumpUntilFound(tester, find.text('Appearance'));
      expect(find.text('Appearance'), findsOneWidget);

      // --- Switch to dark theme, verify it applies immediately ---
      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(Theme.of(tester.element(find.text('Appearance'))).brightness, Brightness.dark);

      // --- Change display currency to EUR ---
      await tester.tap(find.text('USD'));
      await _pumpUntilFound(tester, find.text('EUR'));
      await tester.tap(find.text('EUR').last);
      await _pumpUntilFound(tester, find.text('EUR'));
      expect(find.text('EUR'), findsWidgets);

      // --- Toggle price alerts off ---
      final priceAlertsSwitch = find.widgetWithText(SwitchListTile, 'Price alerts');
      expect(priceAlertsSwitch, findsOneWidget);
      await tester.tap(priceAlertsSwitch);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // --- Notifications inbox reachable from Market, starts empty ---
      await tester.tap(find.text('Market'));
      await _pumpUntilFound(tester, find.byIcon(Icons.notifications_outlined));
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await _pumpUntilFound(tester, find.text('No notifications yet'));
      expect(find.text('No notifications yet'), findsOneWidget);

      await tester.pageBack();
      await _pumpUntilFound(tester, find.widgetWithText(AppBar, 'Market'));

      // --- Switch back to system theme and log out ---
      await tester.tap(find.text('Settings'));
      await _pumpUntilFound(tester, find.text('System'));
      await tester.tap(find.text('System'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Log out'));
      await _pumpUntilFound(tester, find.text('Sign in'));
      expect(find.text('Sign in'), findsOneWidget);
    },
  );
}
