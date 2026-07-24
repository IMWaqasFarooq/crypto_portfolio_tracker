import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/coin_search_result.dart';

part 'coin_search_state.freezed.dart';

enum CoinSearchStatus { idle, loading, success, failure }

@freezed
abstract class CoinSearchState with _$CoinSearchState {
  const factory CoinSearchState({
    @Default('') String query,
    @Default(CoinSearchStatus.idle) CoinSearchStatus status,
    @Default(<CoinSearchResult>[]) List<CoinSearchResult> results,
    Failure? failure,
  }) = _CoinSearchState;
}
