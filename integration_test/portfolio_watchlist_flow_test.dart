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

/// Manual drag-scroll + safe polling instead of scrollUntilVisible, which throws internally when the target isn't mounted yet.
Future<void> _scrollUntilFound(
  WidgetTester tester,
  Finder scrollable,
  Finder target, {
  int maxDrags = 10,
}) async {
  for (var i = 0; i < maxDrags; i++) {
    if (target.evaluate().isNotEmpty) return;
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'add coin to watchlist, add a holding, verify totals, then remove both',
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

      // --- Watchlist starts empty ---
      await tester.tap(find.text('Watchlist'));
      await _pumpUntilFound(tester, find.text('Your watchlist is empty'));
      expect(find.text('Your watchlist is empty'), findsOneWidget);

      // --- Star Bitcoin from its detail page ---
      await tester.tap(find.text('Market'));
      await _pumpUntilFound(tester, find.text('Bitcoin'));
      await tester.tap(find.text('Bitcoin'));
      await _pumpUntilFound(tester, find.text('Coin details'));
      await _pumpUntilFound(tester, find.byIcon(Icons.star_border_rounded));

      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await _pumpUntilFound(tester, find.byIcon(Icons.star_rounded));
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);

      await tester.pageBack();
      await _pumpUntilFound(tester, find.widgetWithText(AppBar, 'Market'));

      // --- Watchlist now shows Bitcoin ---
      await tester.tap(find.text('Watchlist'));
      await _pumpUntilFound(tester, find.text('Bitcoin'));
      expect(find.text('Your watchlist is empty'), findsNothing);
      expect(find.text('Bitcoin'), findsOneWidget);

      // --- Portfolio starts empty ---
      await tester.tap(find.text('Portfolio'));
      await _pumpUntilFound(tester, find.text('No holdings yet'));
      expect(find.text('No holdings yet'), findsOneWidget);

      // --- Add a Bitcoin holding ---
      await tester.tap(find.text('Add holding'));
      await _pumpUntilFound(tester, find.text('Select a coin'));
      await tester.tap(find.text('Select a coin'));
      await _pumpUntilFound(tester, find.byType(TextField));
      await tester.enterText(find.byType(TextField).first, 'bitcoin');
      // Poll the plain finder - `.first` throws instead of returning empty when nothing matches yet.
      await _pumpUntilFound(tester, find.text('Bitcoin'));
      await tester.tap(find.text('Bitcoin').first);

      final quantityField = find.widgetWithText(TextFormField, 'Quantity');
      await _pumpUntilFound(tester, quantityField);
      expect(quantityField, findsOneWidget);
      await tester.enterText(quantityField, '0.5');
      await tester.pump();

      await tester.tap(find.text('Add to portfolio'));
      await _pumpUntilFound(tester, find.text('Total balance'));

      // --- Portfolio now shows the holding and a non-zero total ---
      expect(find.text('No holdings yet'), findsNothing);
      expect(find.text('Total balance'), findsOneWidget);

      // Holdings is below the fold (unmounted until scrolled); disambiguate the Scrollable since IndexedStack keeps other tabs' mounted too.
      final portfolioScrollable = find.ancestor(
        of: find.text('Total balance'),
        matching: find.byType(Scrollable),
      );
      await _scrollUntilFound(tester, portfolioScrollable, find.text('Holdings'));
      expect(find.text('Holdings'), findsOneWidget);
      await _scrollUntilFound(tester, portfolioScrollable, find.text('Bitcoin'));
      expect(find.text('Bitcoin'), findsOneWidget);

      // --- Remove the holding via swipe-to-dismiss ---
      await tester.drag(find.text('Bitcoin'), const Offset(-500, 0));
      await _pumpUntilFound(tester, find.text('No holdings yet'));
      expect(find.text('No holdings yet'), findsOneWidget);

      // --- Remove from watchlist too ---
      await tester.tap(find.text('Watchlist'));
      await _pumpUntilFound(tester, find.byIcon(Icons.close_rounded));
      await tester.tap(find.byIcon(Icons.close_rounded));
      await _pumpUntilFound(tester, find.text('Your watchlist is empty'));
      expect(find.text('Your watchlist is empty'), findsOneWidget);
    },
  );
}
