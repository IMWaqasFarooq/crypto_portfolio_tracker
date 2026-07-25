import 'package:crypto_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/unsubscribe_price_updates_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  test('delegates the subscriber id to the repository', () {
    final repository = _MockMarketRepository();
    when(() => repository.unsubscribeFromPriceUpdates(any())).thenReturn(null);
    final useCase = UnsubscribePriceUpdatesUseCase(repository);

    useCase('sub-1');

    verify(() => repository.unsubscribeFromPriceUpdates('sub-1')).called(1);
  });
}
