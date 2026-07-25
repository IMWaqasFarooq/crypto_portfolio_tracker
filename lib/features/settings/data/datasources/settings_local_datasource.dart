import 'package:hive/hive.dart';

import '../../../../core/services/currency_provider.dart';
import '../../domain/entities/app_settings.dart';

abstract class SettingsLocalDataSource {
  Stream<AppSettings> watchSettings();
  Future<void> updateSettings(AppSettings settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl(this._box, this._currencyProvider);

  final Box<dynamic> _box;
  final CurrencyProvider _currencyProvider;

  static const _themeModeKey = 'theme_mode';
  static const _priceAlertsKey = 'price_alerts_enabled';
  static const _marketNewsKey = 'market_news_enabled';

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _read();
    yield* _box.watch().map((_) => _read());
  }

  AppSettings _read() {
    return AppSettings(
      themeMode: _themeModeFromString((_box.get(_themeModeKey) as String?) ?? 'system'),
      currency: _currencyProvider.currencyCode,
      priceAlertsEnabled: (_box.get(_priceAlertsKey) as bool?) ?? true,
      marketNewsEnabled: (_box.get(_marketNewsKey) as bool?) ?? true,
    );
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await _box.put(_themeModeKey, settings.themeMode.name);
    await _box.put(_priceAlertsKey, settings.priceAlertsEnabled);
    await _box.put(_marketNewsKey, settings.marketNewsEnabled);
    if (settings.currency != _currencyProvider.currencyCode) {
      await _currencyProvider.setCurrency(settings.currency);
    }
  }

  AppThemeMode _themeModeFromString(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
