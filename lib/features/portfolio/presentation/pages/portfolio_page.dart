import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../market/presentation/widgets/price_chart.dart';
import '../../../market/presentation/widgets/timeframe_selector.dart';
import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_history_cubit.dart';
import '../cubit/portfolio_history_state.dart';
import '../cubit/portfolio_state.dart';
import '../widgets/allocation_pie_chart.dart';
import '../widgets/holding_list_tile.dart';
import '../widgets/portfolio_summary_card.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PortfolioHistoryCubit>(),
      child: const _PortfolioView(),
    );
  }
}

class _PortfolioView extends StatelessWidget {
  const _PortfolioView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add holding',
            onPressed: () => context.push(RoutePaths.addHolding),
          ),
        ],
      ),
      body: BlocListener<PortfolioCubit, PortfolioState>(
        listenWhen: (previous, current) => previous.holdings != current.holdings,
        listener: (context, state) {
          if (state.holdings.isNotEmpty) {
            context.read<PortfolioHistoryCubit>().load(state.holdings);
          }
        },
        child: BlocBuilder<PortfolioCubit, PortfolioState>(
          buildWhen: (previous, current) =>
              previous.status != current.status || previous.holdings != current.holdings,
          builder: (context, state) {
            if (state.status == PortfolioStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.holdings.isEmpty) {
              return EmptyStateView(
                icon: Icons.pie_chart_outline_rounded,
                title: 'No holdings yet',
                message: 'Add a coin you own to start tracking your portfolio',
                action: FilledButton.icon(
                  onPressed: () => context.push(RoutePaths.addHolding),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add holding'),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                BlocSelector<PortfolioCubit, PortfolioState, ({double value, double pl, double plPercent})>(
                  selector: (state) => (
                    value: state.totalValue,
                    pl: state.totalProfitLoss,
                    plPercent: state.totalProfitLossPercent,
                  ),
                  builder: (context, totals) => PortfolioSummaryCard(
                    totalValue: totals.value,
                    totalProfitLoss: totals.pl,
                    totalProfitLossPercent: totals.plPercent,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Allocation', style: AppTextStyles.sectionTitle(context)),
                const SizedBox(height: AppSpacing.sm),
                BlocSelector<PortfolioCubit, PortfolioState, List<double>>(
                  selector: (state) =>
                      [for (final holding in state.holdings) state.allocationPercentFor(holding)],
                  builder: (context, percentages) => AllocationPieChart(
                    holdings: state.holdings,
                    percentages: percentages,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('History', style: AppTextStyles.sectionTitle(context)),
                const SizedBox(height: AppSpacing.sm),
                BlocBuilder<PortfolioHistoryCubit, PortfolioHistoryState>(
                  builder: (context, historyState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (historyState.status == PortfolioHistoryStatus.loading ||
                            historyState.status == PortfolioHistoryStatus.initial)
                          const SizedBox(
                            height: 220,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (historyState.status == PortfolioHistoryStatus.failure)
                          ErrorStateView(failure: historyState.failure!)
                        else
                          PriceChart(points: historyState.points),
                        const SizedBox(height: AppSpacing.sm),
                        TimeframeSelector(
                          selectedDays: historyState.selectedDays,
                          onChanged: (days) => context
                              .read<PortfolioHistoryCubit>()
                              .load(state.holdings, days: days),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Holdings', style: AppTextStyles.sectionTitle(context)),
                const SizedBox(height: AppSpacing.sm),
                for (final holding in state.holdings)
                  BlocSelector<PortfolioCubit, PortfolioState, ({double value, double pl})>(
                    selector: (state) => (
                      value: state.valueFor(holding),
                      pl: state.profitLossPercentFor(holding),
                    ),
                    builder: (context, row) => HoldingListTile(
                      holding: holding,
                      currentValue: row.value,
                      profitLossPercent: row.pl,
                      onTap: () => context.push(RoutePaths.coinDetailPath(holding.coinId)),
                      onDelete: () => context.read<PortfolioCubit>().removeHolding(holding.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
