import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/price_point.dart';

class PriceChart extends StatelessWidget {
  const PriceChart({super.key, required this.points});

  final List<PricePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox(height: 220, child: Center(child: Text('Not enough data')));
    }

    final isPositive = points.last.price >= points.first.price;
    final color = AppColors.priceChangeColor(isPositive ? 1 : -1);
    final minY = points.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.inverseSurface,
              getTooltipItems: (spots) => spots.map((spot) {
                final point = points[spot.x.toInt()];
                return LineTooltipItem(
                  NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(point.price),
                  TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].price),
              ],
              isCurved: true,
              curveSmoothness: 0.2,
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
