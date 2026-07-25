import 'package:crypto_portfolio_tracker/features/settings/domain/entities/app_settings.dart';
import 'package:crypto_portfolio_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:crypto_portfolio_tracker/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:crypto_portfolio_tracker/features/settings/domain/usecases/watch_settings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;

  const settings = AppSettings(
    themeMode: AppThemeMode.dark,
    currency: 'eur',
    priceAlertsEnabled: false,
    marketNewsEnabled: true,
  );

  setUpAll(() => registerFallbackValue(settings));

  setUp(() {
    repository = _MockSettingsRepository();
  });

  test('WatchSettingsUseCase delegates to the repository stream', () {
    when(() => repository.watchSettings()).thenAnswer((_) => Stream.value(settings));

    final stream = WatchSettingsUseCase(repository)();

    expect(stream, emits(settings));
  });

  test('UpdateSettingsUseCase delegates the new settings to the repository', () async {
    when(() => repository.updateSettings(any())).thenAnswer((_) async {});

    await UpdateSettingsUseCase(repository)(settings);

    verify(() => repository.updateSettings(settings)).called(1);
  });
}
