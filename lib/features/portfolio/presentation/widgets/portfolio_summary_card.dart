import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/price_change_badge.dart';

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({
    super.key,
    required this.totalValue,
    required this.totalProfitLoss,
    required this.totalProfitLossPercent,
  });

  final double totalValue;
  final double totalProfitLoss;
  final double totalProfitLossPercent;

  @override
  Widget build(BuildContext context) {
    // Values are Binance-tick-sourced (always USD), independent of the Settings currency.
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total balance', style: AppTextStyles.caption(context)),
          const SizedBox(height: AppSpacing.xxs),
          Text(currency.format(totalValue), style: AppTextStyles.priceLarge(context)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                '${totalProfitLoss >= 0 ? '+' : ''}${currency.format(totalProfitLoss)}',
                style: AppTextStyles.priceChange(context).copyWith(
                      color: AppColors.priceChangeColor(totalProfitLoss),
                    ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PriceChangeBadge(changePercent: totalProfitLossPercent, dense: true),
            ],
          ),
        ],
      ),
    );
  }
}
