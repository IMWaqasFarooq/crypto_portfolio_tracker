import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/coin_avatar.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../../market/domain/entities/price_tick.dart';
import '../../domain/entities/watchlist_item.dart';

class WatchlistListTile extends StatelessWidget {
  const WatchlistListTile({
    super.key,
    required this.item,
    required this.liveTick,
    required this.onTap,
    required this.onRemove,
  });

  final WatchlistItem item;
  final PriceTick? liveTick;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tick = liveTick;

    return ListTile(
      onTap: onTap,
      leading: CoinAvatar(imageUrl: item.imageUrl, symbol: item.symbol),
      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.symbol.toUpperCase(), style: AppTextStyles.caption(context)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tick != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: '\$', decimalDigits: tick.price < 1 ? 4 : 2)
                      .format(tick.price),
                  style: AppTextStyles.priceMedium(context),
                ),
                const SizedBox(height: 2),
                PriceChangeBadge(changePercent: tick.changePercent24h, dense: true),
              ],
            )
          else
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Remove from watchlist',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
