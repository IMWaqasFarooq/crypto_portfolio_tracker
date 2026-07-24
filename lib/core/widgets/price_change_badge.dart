import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A signed percentage pill, colored bullish (green) or bearish (red).
class PriceChangeBadge extends StatelessWidget {
  const PriceChangeBadge({super.key, required this.changePercent, this.dense = false});

  final double changePercent;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.priceChangeColor(changePercent);
    final isPositive = changePercent >= 0;
    final text = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
        vertical: dense ? 2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
            size: dense ? 14 : 18,
            color: color,
          ),
          Text(text, style: AppTextStyles.priceChange(context).copyWith(color: color)),
        ],
      ),
    );
  }
}
