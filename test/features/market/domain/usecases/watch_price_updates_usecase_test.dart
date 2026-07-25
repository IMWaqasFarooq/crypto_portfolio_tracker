import 'package:crypto_portfolio_tracker/features/market/domain/entities/price_tick.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:crypto_portfolio_tracker/features/market/domain/usecases/watch_price_updates_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late _MockMarketRepository repository;
  late WatchPriceUpdatesUseCase useCase;

  setUp(() {
    repository = _MockMarketRepository();
    useCase = WatchPriceUpdatesUseCase(repository);
  });

  test('subscribes the caller and returns the shared tick stream', () async {
    const tick = PriceTick(symbol: 'btc', price: 64000, changePercent24h: -1.6);
    when(() => repository.subscribeToPriceUpdates(any(), any())).thenReturn(null);
    when(() => repository.priceTicks).thenAnswer((_) => Stream.value(tick));

    final stream = useCase(
      const WatchPriceUpdatesParams(subscriberId: 'sub-1', symbols: ['btc']),
    );

    await expectLater(stream, emits(tick));
    verify(() => repository.subscribeToPriceUpdates('sub-1', ['btc'])).called(1);
  });
}
