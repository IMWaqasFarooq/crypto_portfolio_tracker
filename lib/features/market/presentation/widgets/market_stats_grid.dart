import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/coin_detail.dart';

class MarketStatsGrid extends StatelessWidget {
  const MarketStatsGrid({super.key, required this.coin});

  final CoinDetail coin;

  @override
  Widget build(BuildContext context) {
    final symbol = sl<CurrencyProvider>().symbol;
    final currency = NumberFormat.compactCurrency(symbol: symbol);
    final price = NumberFormat.currency(symbol: symbol, decimalDigits: 2);

    final stats = <(String, String)>[
      ('Market Cap', currency.format(coin.marketCap)),
      ('24h Volume', currency.format(coin.totalVolume)),
      ('24h High', price.format(coin.high24h)),
      ('24h Low', price.format(coin.low24h)),
      ('All-Time High', price.format(coin.ath)),
      ('All-Time Low', price.format(coin.atl)),
      if (coin.circulatingSupply != null)
        ('Circulating Supply', NumberFormat.compact().format(coin.circulatingSupply)),
      if (coin.maxSupply != null) ('Max Supply', NumberFormat.compact().format(coin.maxSupply)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final (label, value) = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        );
      },
    );
  }
}
