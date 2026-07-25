import 'package:crypto_portfolio_tracker/core/services/currency_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class _MockBox extends Mock implements Box<dynamic> {}

void main() {
  late _MockBox box;
  late CurrencyProvider provider;

  setUp(() {
    box = _MockBox();
    provider = CurrencyProvider(box);
  });

  test('currencyCode falls back to the default when nothing is stored', () {
    when(() => box.get('currency')).thenReturn(null);

    expect(provider.currencyCode, 'usd');
  });

  test('currencyCode returns the stored value', () {
    when(() => box.get('currency')).thenReturn('eur');

    expect(provider.currencyCode, 'eur');
  });

  test('symbol maps known currency codes to their symbol', () {
    when(() => box.get('currency')).thenReturn('gbp');

    expect(provider.symbol, '£');
  });

  test('symbol falls back to the uppercased code for unknown currencies', () {
    when(() => box.get('currency')).thenReturn('xyz');

    expect(provider.symbol, 'XYZ');
  });

  test('setCurrency lowercases and persists the code', () async {
    when(() => box.put(any(), any())).thenAnswer((_) async {});

    await provider.setCurrency('EUR');

    verify(() => box.put('currency', 'eur')).called(1);
  });

  test('watch emits the current value immediately, then again on every box change', () async {
    when(() => box.get('currency')).thenReturn('usd');
    when(() => box.watch(key: any(named: 'key'))).thenAnswer((_) => const Stream.empty());

    final stream = provider.watch();

    await expectLater(stream, emits('usd'));
  });
}
