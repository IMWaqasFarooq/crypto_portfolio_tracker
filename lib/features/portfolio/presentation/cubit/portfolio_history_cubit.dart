import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/holding.dart';
import '../../domain/usecases/get_portfolio_history_usecase.dart';
import 'portfolio_history_state.dart';

class PortfolioHistoryCubit extends Cubit<PortfolioHistoryState> {
  PortfolioHistoryCubit({required GetPortfolioHistoryUseCase getPortfolioHistoryUseCase})
      : _getPortfolioHistoryUseCase = getPortfolioHistoryUseCase,
        super(const PortfolioHistoryState());

  final GetPortfolioHistoryUseCase _getPortfolioHistoryUseCase;

  Future<void> load(List<Holding> holdings, {int? days}) async {
    final selectedDays = days ?? state.selectedDays;
    emit(state.copyWith(status: PortfolioHistoryStatus.loading, selectedDays: selectedDays));

    final result = await _getPortfolioHistoryUseCase(
      GetPortfolioHistoryParams(holdings: holdings, days: selectedDays),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: PortfolioHistoryStatus.failure, failure: failure)),
      (points) => emit(
        state.copyWith(status: PortfolioHistoryStatus.success, points: points, failure: null),
      ),
    );
  }
}
