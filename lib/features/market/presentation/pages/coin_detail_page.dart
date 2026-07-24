import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/coin_avatar.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../bloc/coin_detail_bloc.dart';
import '../bloc/coin_detail_event.dart';
import '../bloc/coin_detail_state.dart';
import '../widgets/market_stats_grid.dart';
import '../widgets/price_chart.dart';
import '../widgets/timeframe_selector.dart';

class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({super.key, required this.coinId});

  final String coinId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoinDetailBloc>()..add(CoinDetailEvent.started(coinId)),
      child: const _CoinDetailView(),
    );
  }
}

class _CoinDetailView extends StatelessWidget {
  const _CoinDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin details')),
      body: BlocBuilder<CoinDetailBloc, CoinDetailState>(
        builder: (context, state) {
          if (state.detailStatus == DetailStatus.initial || state.detailStatus == DetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.detailStatus == DetailStatus.failure) {
            return ErrorStateView(
              failure: state.detailFailure!,
              onRetry: () => context.read<CoinDetailBloc>().add(const CoinDetailEvent.refreshed()),
            );
          }

          final coin = state.coin!;
          final price = NumberFormat.currency(symbol: '\$', decimalDigits: coin.currentPrice < 1 ? 4 : 2);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CoinDetailBloc>().add(const CoinDetailEvent.refreshed());
              await context.read<CoinDetailBloc>().stream.firstWhere(
                    (s) => s.detailStatus != DetailStatus.loading,
                  );
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Row(
                  children: [
                    CoinAvatar(imageUrl: coin.imageUrl, symbol: coin.symbol, size: 48),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coin.name, style: AppTextStyles.sectionTitle(context)),
                          Text(coin.symbol.toUpperCase(), style: AppTextStyles.caption(context)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(price.format(coin.currentPrice), style: AppTextStyles.priceLarge(context)),
                const SizedBox(height: AppSpacing.xxs),
                PriceChangeBadge(changePercent: coin.priceChangePercentage24h),
                const SizedBox(height: AppSpacing.lg),
                if (state.chartStatus == ChartStatus.loading)
                  const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
                else if (state.chartStatus == ChartStatus.failure)
                  ErrorStateView(failure: state.chartFailure!)
                else
                  PriceChart(points: state.pricePoints),
                const SizedBox(height: AppSpacing.sm),
                TimeframeSelector(
                  selectedDays: state.selectedDays,
                  onChanged: (days) =>
                      context.read<CoinDetailBloc>().add(CoinDetailEvent.timeframeChanged(days)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Market stats', style: AppTextStyles.sectionTitle(context)),
                const SizedBox(height: AppSpacing.sm),
                MarketStatsGrid(coin: coin),
                if (coin.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('About ${coin.name}', style: AppTextStyles.sectionTitle(context)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(coin.description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
