import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/coin_avatar.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../domain/entities/coin.dart';

class CoinListTile extends StatelessWidget {
  const CoinListTile({super.key, required this.coin, required this.onTap});

  final Coin coin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: coin.currentPrice < 1 ? 4 : 2);

    return ListTile(
      onTap: onTap,
      leading: CoinAvatar(imageUrl: coin.imageUrl, symbol: coin.symbol),
      title: Text(coin.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(coin.symbol.toUpperCase(), style: AppTextStyles.caption(context)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(priceFormat.format(coin.currentPrice), style: AppTextStyles.priceMedium(context)),
          const SizedBox(height: AppSpacing.xxs),
          PriceChangeBadge(changePercent: coin.priceChangePercentage24h, dense: true),
        ],
      ),
    );
  }
}
