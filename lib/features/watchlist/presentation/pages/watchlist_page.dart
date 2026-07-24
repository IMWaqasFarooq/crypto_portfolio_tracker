import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../cubit/watchlist_cubit.dart';
import '../cubit/watchlist_state.dart';
import '../widgets/watchlist_list_tile.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (context, state) {
          if (state.status == WatchlistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const EmptyStateView(
              icon: Icons.star_border_rounded,
              title: 'Your watchlist is empty',
              message: 'Star a coin from its detail page to track it here',
            );
          }
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return WatchlistListTile(
                item: item,
                liveTick: state.liveTicks[item.symbol.toLowerCase()],
                onTap: () => context.push(RoutePaths.coinDetailPath(item.coinId)),
                onRemove: () => context.read<WatchlistCubit>().toggle(item),
              );
            },
          );
        },
      ),
    );
  }
}
