import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/coin_search_result.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/search_coins_usecase.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/coin_search_cubit.dart';
import 'package:crypto_portfolio_tracker/features/market/presentation/bloc/coin_search_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearchCoinsUseCase extends Mock implements SearchCoinsUseCase {}

void main() {
  late _MockSearchCoinsUseCase searchCoinsUseCase;

  setUp(() {
    searchCoinsUseCase = _MockSearchCoinsUseCase();
  });

  const results = [
    CoinSearchResult(
      id: 'bitcoin',
      symbol: 'btc',
      name: 'Bitcoin',
      thumbnailUrl: 'https://example.com/btc-thumb.png',
      marketCapRank: 1,
    ),
  ];

  blocTest<CoinSearchCubit, CoinSearchState>(
    'debounces then emits [loading, success] after the query settles',
    build: () {
      when(() => searchCoinsUseCase(any())).thenAnswer((_) async => const Right(results));
      return CoinSearchCubit(searchCoinsUseCase: searchCoinsUseCase);
    },
    act: (cubit) => cubit.queryChanged('bitcoin'),
    wait: const Duration(milliseconds: 500),
    expect: () => [
      const CoinSearchState(query: 'bitcoin'),
      const CoinSearchState(query: 'bitcoin', status: CoinSearchStatus.loading),
      const CoinSearchState(query: 'bitcoin', status: CoinSearchStatus.success, results: results),
    ],
  );

  blocTest<CoinSearchCubit, CoinSearchState>(
    'clears results immediately when the query is emptied, without searching',
    build: () => CoinSearchCubit(searchCoinsUseCase: searchCoinsUseCase),
    act: (cubit) {
      cubit.queryChanged('bitcoin');
      cubit.queryChanged('');
    },
    expect: () => [
      const CoinSearchState(query: 'bitcoin'),
      const CoinSearchState(),
    ],
    verify: (_) => verifyNever(() => searchCoinsUseCase(any())),
  );

  blocTest<CoinSearchCubit, CoinSearchState>(
    'ignores repeated calls with the same query (SearchDelegate rebuild guard)',
    build: () {
      when(() => searchCoinsUseCase(any())).thenAnswer((_) async => const Right(results));
      return CoinSearchCubit(searchCoinsUseCase: searchCoinsUseCase);
    },
    act: (cubit) {
      cubit.queryChanged('bitcoin');
      cubit.queryChanged('bitcoin');
      cubit.queryChanged('bitcoin');
    },
    wait: const Duration(milliseconds: 500),
    verify: (_) => verify(() => searchCoinsUseCase('bitcoin')).called(1),
  );

  blocTest<CoinSearchCubit, CoinSearchState>(
    'emits failure when the search fails',
    build: () {
      when(() => searchCoinsUseCase(any())).thenAnswer((_) async => const Left(Failure.network()));
      return CoinSearchCubit(searchCoinsUseCase: searchCoinsUseCase);
    },
    act: (cubit) => cubit.queryChanged('bitcoin'),
    wait: const Duration(milliseconds: 500),
    expect: () => [
      const CoinSearchState(query: 'bitcoin'),
      const CoinSearchState(query: 'bitcoin', status: CoinSearchStatus.loading),
      const CoinSearchState(
        query: 'bitcoin',
        status: CoinSearchStatus.failure,
        failure: Failure.network(),
      ),
    ],
  );
}
