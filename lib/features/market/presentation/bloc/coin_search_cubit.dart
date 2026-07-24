import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_coins_usecase.dart';
import 'coin_search_state.dart';

class CoinSearchCubit extends Cubit<CoinSearchState> {
  CoinSearchCubit({required SearchCoinsUseCase searchCoinsUseCase})
      : _searchCoinsUseCase = searchCoinsUseCase,
        super(const CoinSearchState());

  final SearchCoinsUseCase _searchCoinsUseCase;
  Timer? _debounce;

  void queryChanged(String query) {
    // buildSuggestions() calls this on every SearchDelegate rebuild, not just
    // when the text actually changes - without this guard, frequent rebuilds
    // (e.g. one per pump/frame) keep restarting the debounce timer and a
    // search is never actually dispatched.
    if (query == state.query) return;

    _debounce?.cancel();
    emit(state.copyWith(query: query));

    if (query.trim().isEmpty) {
      emit(state.copyWith(status: CoinSearchStatus.idle, results: const []));
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    emit(state.copyWith(status: CoinSearchStatus.loading));
    final result = await _searchCoinsUseCase(query);
    result.fold(
      (failure) => emit(state.copyWith(status: CoinSearchStatus.failure, failure: failure)),
      (results) => emit(
        state.copyWith(status: CoinSearchStatus.success, results: results, failure: null),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
