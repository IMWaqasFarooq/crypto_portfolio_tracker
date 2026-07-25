import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/coin_avatar.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../domain/entities/holding.dart';

class HoldingListTile extends StatelessWidget {
  const HoldingListTile({
    super.key,
    required this.holding,
    required this.currentValue,
    required this.profitLossPercent,
    required this.onTap,
    required this.onDelete,
  });

  final Holding holding;
  final double currentValue;
  final double profitLossPercent;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Binance-tick-sourced (always USD), independent of the Settings currency.
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final quantityFormat = NumberFormat.decimalPattern()..maximumFractionDigits = 6;

    return Dismissible(
      key: ValueKey(holding.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: CoinAvatar(imageUrl: holding.imageUrl, symbol: holding.symbol),
        title: Text(holding.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${quantityFormat.format(holding.quantity)} ${holding.symbol.toUpperCase()}',
          style: AppTextStyles.caption(context),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(currency.format(currentValue), style: AppTextStyles.priceMedium(context)),
            const SizedBox(height: 2),
            PriceChangeBadge(changePercent: profitLossPercent, dense: true),
          ],
        ),
      ),
    );
  }
}
