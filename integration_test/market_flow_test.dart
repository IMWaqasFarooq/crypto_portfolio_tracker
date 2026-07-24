import 'package:crypto_portfolio_tracker/app.dart';
import 'package:crypto_portfolio_tracker/core/config/flavor.dart';
import 'package:crypto_portfolio_tracker/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'login, browse market list, open coin detail with live chart',
    (tester) async {
      await sl.reset();
      await configureDependencies(Flavor.development);
      registerObservabilityServices(firebaseAvailable: false);
      await tester.pumpWidget(const CryptofolioApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      if (find.text('Sign in').evaluate().isNotEmpty) {
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'demo@cryptofolio.dev');
        await tester.enterText(fields.at(1), 'password123');
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Real CoinGecko network call - allow generous time to settle.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.widgetWithText(AppBar, 'Market'), findsOneWidget);
      expect(find.text('Bitcoin'), findsOneWidget);

      await tester.tap(find.text('Bitcoin'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Coin details'), findsOneWidget);
      expect(find.text('Market stats'), findsOneWidget);
      expect(find.text('24h High'), findsOneWidget);

      await tester.tap(find.text('7D'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Market'), findsOneWidget);
    },
  );
}
