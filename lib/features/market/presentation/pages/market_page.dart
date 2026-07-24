import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../bloc/coin_search_cubit.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/coin_list_tile.dart';
import '../widgets/coin_search_delegate.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MarketBloc>()..add(const MarketEvent.started()),
      child: const _MarketView(),
    );
  }
}

class _MarketView extends StatefulWidget {
  const _MarketView();

  @override
  State<_MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<_MarketView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MarketBloc>().add(const MarketEvent.loadMoreRequested());
    }
  }

  Future<void> _openSearch() async {
    final coinId = await showSearch<String?>(
      context: context,
      delegate: CoinSearchDelegate(sl<CoinSearchCubit>()),
    );
    if (coinId != null && mounted) {
      context.push(RoutePaths.coinDetailPath(coinId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: _openSearch),
        ],
      ),
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          if (state.status == MarketStatus.initial || state.status == MarketStatus.loading) {
            return const SkeletonList();
          }
          if (state.status == MarketStatus.failure && state.coins.isEmpty) {
            return ErrorStateView(
              failure: state.failure!,
              onRetry: () => context.read<MarketBloc>().add(const MarketEvent.started()),
            );
          }
          if (state.coins.isEmpty) {
            return const EmptyStateView(
              icon: Icons.currency_bitcoin_rounded,
              title: 'No coins available',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<MarketBloc>().add(const MarketEvent.refreshed());
              await context.read<MarketBloc>().stream.firstWhere(
                    (s) => s.status != MarketStatus.loading,
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.coins.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.coins.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final coin = state.coins[index];
                return CoinListTile(
                  coin: coin,
                  onTap: () => context.push(RoutePaths.coinDetailPath(coin.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
