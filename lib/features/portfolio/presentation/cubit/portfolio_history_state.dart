import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../market/domain/entities/price_point.dart';

part 'portfolio_history_state.freezed.dart';

enum PortfolioHistoryStatus { initial, loading, success, failure }

@freezed
abstract class PortfolioHistoryState with _$PortfolioHistoryState {
  const factory PortfolioHistoryState({
    @Default(PortfolioHistoryStatus.initial) PortfolioHistoryStatus status,
    @Default(<PricePoint>[]) List<PricePoint> points,
    @Default(7) int selectedDays,
    Failure? failure,
  }) = _PortfolioHistoryState;
}
