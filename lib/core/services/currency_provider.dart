import 'package:hive/hive.dart';

const supportedCurrencies = ['usd', 'eur', 'gbp', 'jpy', 'aud', 'cad', 'inr'];

const _currencySymbols = {
  'usd': '\$',
  'eur': '€',
  'gbp': '£',
  'jpy': '¥',
  'aud': 'A\$',
  'cad': 'C\$',
  'inr': '₹',
};

/// Single source of truth for the selected display currency, shared between
/// Settings (writes it) and Market (reads it for CoinGecko's vs_currency).
class CurrencyProvider {
  CurrencyProvider(this._box);

  final Box<dynamic> _box;
  static const _key = 'currency';
  static const defaultCurrency = 'usd';

  String get currencyCode => (_box.get(_key) as String?) ?? defaultCurrency;

  String get symbol => _currencySymbols[currencyCode] ?? currencyCode.toUpperCase();

  Stream<String> watch() async* {
    yield currencyCode;
    yield* _box.watch(key: _key).map((_) => currencyCode);
  }

  Future<void> setCurrency(String code) => _box.put(_key, code.toLowerCase());
}
