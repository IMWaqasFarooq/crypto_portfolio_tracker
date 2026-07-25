import 'dart:async';

import 'package:crypto_portfolio_tracker/features/settings/domain/entities/app_settings.dart';
import 'package:crypto_portfolio_tracker/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:crypto_portfolio_tracker/features/settings/domain/usecases/watch_settings_usecase.dart';
import 'package:crypto_portfolio_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchSettingsUseCase extends Mock implements WatchSettingsUseCase {}

class _MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

void main() {
  late _MockWatchSettingsUseCase watchSettingsUseCase;
  late _MockUpdateSettingsUseCase updateSettingsUseCase;
  late StreamController<AppSettings> controller;

  setUpAll(() => registerFallbackValue(AppSettings.defaults));

  setUp(() {
    watchSettingsUseCase = _MockWatchSettingsUseCase();
    updateSettingsUseCase = _MockUpdateSettingsUseCase();
    controller = StreamController<AppSettings>.broadcast();

    when(() => watchSettingsUseCase()).thenAnswer((_) => controller.stream);
    when(() => updateSettingsUseCase(any())).thenAnswer((_) async {});
  });

  tearDown(() => controller.close());

  SettingsCubit buildCubit() => SettingsCubit(
        watchSettingsUseCase: watchSettingsUseCase,
        updateSettingsUseCase: updateSettingsUseCase,
      );

  test('reflects the latest settings emitted by the repository stream', () async {
    final cubit = buildCubit();
    const updated = AppSettings(
      themeMode: AppThemeMode.dark,
      currency: 'eur',
      priceAlertsEnabled: true,
      marketNewsEnabled: true,
    );

    controller.add(updated);
    await pumpEventQueue();

    expect(cubit.state.settings, updated);

    await cubit.close();
  });

  test('setThemeMode updates only the theme mode field', () async {
    final cubit = buildCubit();

    await cubit.setThemeMode(AppThemeMode.dark);

    verify(() => updateSettingsUseCase(
          AppSettings.defaults.copyWith(themeMode: AppThemeMode.dark),
        )).called(1);

    await cubit.close();
  });

  test('setCurrency updates only the currency field', () async {
    final cubit = buildCubit();

    await cubit.setCurrency('eur');

    verify(() => updateSettingsUseCase(AppSettings.defaults.copyWith(currency: 'eur'))).called(1);

    await cubit.close();
  });

  test('setPriceAlertsEnabled updates only the price alerts field', () async {
    final cubit = buildCubit();

    await cubit.setPriceAlertsEnabled(false);

    verify(() => updateSettingsUseCase(
          AppSettings.defaults.copyWith(priceAlertsEnabled: false),
        )).called(1);

    await cubit.close();
  });

  test('setMarketNewsEnabled updates only the market news field', () async {
    final cubit = buildCubit();

    await cubit.setMarketNewsEnabled(false);

    verify(() => updateSettingsUseCase(
          AppSettings.defaults.copyWith(marketNewsEnabled: false),
        )).called(1);

    await cubit.close();
  });
}
