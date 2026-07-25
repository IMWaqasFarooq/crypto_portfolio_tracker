import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_point.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/domain/usecases/get_portfolio_history_usecase.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/presentation/cubit/portfolio_history_cubit.dart';
import 'package:crypto_portfolio_tracker/features/portfolio/presentation/cubit/portfolio_history_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPortfolioHistoryUseCase extends Mock implements GetPortfolioHistoryUseCase {}

void main() {
  late _MockGetPortfolioHistoryUseCase getPortfolioHistoryUseCase;

  setUpAll(() {
    registerFallbackValue(const GetPortfolioHistoryParams(holdings: [], days: 7));
  });

  setUp(() {
    getPortfolioHistoryUseCase = _MockGetPortfolioHistoryUseCase();
  });

  final points = [PricePoint(timestamp: DateTime(2026, 1, 1), price: 1000)];

  blocTest<PortfolioHistoryCubit, PortfolioHistoryState>(
    'emits [loading, success] and keeps the default 7-day window',
    build: () {
      when(() => getPortfolioHistoryUseCase(any())).thenAnswer((_) async => Right(points));
      return PortfolioHistoryCubit(getPortfolioHistoryUseCase: getPortfolioHistoryUseCase);
    },
    act: (cubit) => cubit.load(const []),
    expect: () => [
      const PortfolioHistoryState(status: PortfolioHistoryStatus.loading),
      PortfolioHistoryState(status: PortfolioHistoryStatus.success, points: points),
    ],
    verify: (_) => verify(
      () => getPortfolioHistoryUseCase(const GetPortfolioHistoryParams(holdings: [], days: 7)),
    ).called(1),
  );

  blocTest<PortfolioHistoryCubit, PortfolioHistoryState>(
    'switches the selected window when a custom days value is passed',
    build: () {
      when(() => getPortfolioHistoryUseCase(any())).thenAnswer((_) async => Right(points));
      return PortfolioHistoryCubit(getPortfolioHistoryUseCase: getPortfolioHistoryUseCase);
    },
    act: (cubit) => cubit.load(const [], days: 30),
    expect: () => [
      const PortfolioHistoryState(status: PortfolioHistoryStatus.loading, selectedDays: 30),
      PortfolioHistoryState(status: PortfolioHistoryStatus.success, points: points, selectedDays: 30),
    ],
  );

  blocTest<PortfolioHistoryCubit, PortfolioHistoryState>(
    'emits a failure when the history fails to load',
    build: () {
      when(() => getPortfolioHistoryUseCase(any()))
          .thenAnswer((_) async => const Left(Failure.network()));
      return PortfolioHistoryCubit(getPortfolioHistoryUseCase: getPortfolioHistoryUseCase);
    },
    act: (cubit) => cubit.load(const []),
    expect: () => [
      const PortfolioHistoryState(status: PortfolioHistoryStatus.loading),
      const PortfolioHistoryState(status: PortfolioHistoryStatus.failure, failure: Failure.network()),
    ],
  );

  blocTest<PortfolioHistoryCubit, PortfolioHistoryState>(
    'reuses the previously selected window when days is omitted',
    build: () {
      when(() => getPortfolioHistoryUseCase(any())).thenAnswer((_) async => Right(points));
      return PortfolioHistoryCubit(getPortfolioHistoryUseCase: getPortfolioHistoryUseCase);
    },
    seed: () => const PortfolioHistoryState(selectedDays: 90),
    act: (cubit) => cubit.load(const []),
    verify: (_) => verify(
      () => getPortfolioHistoryUseCase(const GetPortfolioHistoryParams(holdings: [], days: 90)),
    ).called(1),
  );
}
