import 'package:crypto_portfolio_tracker/core/widgets/price_change_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows a leading + and an up arrow for a positive change', (tester) async {
    await tester.pumpWidget(wrap(const PriceChangeBadge(changePercent: 5.2)));

    expect(find.text('+5.20%'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_up_rounded), findsOneWidget);
  });

  testWidgets('shows no leading + and a down arrow for a negative change', (tester) async {
    await tester.pumpWidget(wrap(const PriceChangeBadge(changePercent: -3.14159)));

    expect(find.text('-3.14%'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down_rounded), findsOneWidget);
  });

  testWidgets('treats exactly zero as positive', (tester) async {
    await tester.pumpWidget(wrap(const PriceChangeBadge(changePercent: 0)));

    expect(find.text('+0.00%'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_up_rounded), findsOneWidget);
  });
}
