import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/holding.dart';

/// A fixed, distinct palette cycled by index.
const _sliceColors = [
  Color(0xFF5B5FEF),
  Color(0xFF16C784),
  Color(0xFFF5A623),
  Color(0xFFEA3943),
  Color(0xFF00B8D9),
  Color(0xFF9013FE),
  Color(0xFFE91E63),
  Color(0xFF795548),
];

class AllocationPieChart extends StatelessWidget {
  const AllocationPieChart({
    super.key,
    required this.holdings,
    required this.allocationPercentFor,
  });

  final List<Holding> holdings;
  final double Function(Holding) allocationPercentFor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: [
                for (var i = 0; i < holdings.length; i++)
                  PieChartSectionData(
                    value: allocationPercentFor(holdings[i]),
                    color: _sliceColors[i % _sliceColors.length],
                    showTitle: false,
                    radius: 36,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < holdings.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _sliceColors[i % _sliceColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          holdings[i].symbol.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        '${allocationPercentFor(holdings[i]).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
