import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/coin_avatar.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../bloc/coin_search_cubit.dart';
import '../bloc/coin_search_state.dart';

/// Wraps [CoinSearchCubit] behind Flutter's built-in [SearchDelegate] so
/// search gets a native full-screen search UI (keyboard focus, back/clear
/// affordances) for free.
class CoinSearchDelegate extends SearchDelegate<String?> {
  CoinSearchDelegate(this._cubit);

  final CoinSearchCubit _cubit;

  @override
  void showResults(BuildContext context) => _cubit.queryChanged(query);

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    _cubit.queryChanged(query);
    return _buildResults();
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults();

  Widget _buildResults() {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CoinSearchCubit, CoinSearchState>(
        builder: (context, state) {
          if (state.status == CoinSearchStatus.idle) {
            return const EmptyStateView(
              icon: Icons.search_rounded,
              title: 'Search for a coin',
              message: 'Try "bitcoin", "eth", or a token symbol',
            );
          }
          if (state.status == CoinSearchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CoinSearchStatus.failure) {
            return ErrorStateView(
              failure: state.failure!,
              onRetry: () => _cubit.queryChanged(state.query),
            );
          }
          if (state.results.isEmpty) {
            return const EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'No results',
              message: 'Try a different search term',
            );
          }
          return ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final result = state.results[index];
              return ListTile(
                leading: CoinAvatar(imageUrl: result.thumbnailUrl, symbol: result.symbol),
                title: Text(result.name),
                subtitle: Text(result.symbol.toUpperCase()),
                onTap: () => close(context, result.id),
              );
            },
          );
        },
      ),
    );
  }
}
