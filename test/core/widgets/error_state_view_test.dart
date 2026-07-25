import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/core/widgets/error_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows a network-specific title and icon for a network failure', (tester) async {
    await tester.pumpWidget(wrap(const ErrorStateView(failure: Failure.network())));

    // Both the title and the default failure message read "No internet connection".
    expect(find.text('No internet connection'), findsNWidgets(2));
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
  });

  testWidgets('shows the failure message', (tester) async {
    await tester.pumpWidget(
      wrap(const ErrorStateView(failure: Failure.server(message: 'Rate limited'))),
    );

    expect(find.text('Rate limited'), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('hides the retry button when onRetry is null', (tester) async {
    await tester.pumpWidget(wrap(const ErrorStateView(failure: Failure.network())));

    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('invokes onRetry when the retry button is tapped', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      wrap(ErrorStateView(failure: const Failure.network(), onRetry: () => retried = true)),
    );

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
