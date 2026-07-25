import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/update_settings_usecase.dart';
import '../../domain/usecases/watch_settings_usecase.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required WatchSettingsUseCase watchSettingsUseCase,
    required UpdateSettingsUseCase updateSettingsUseCase,
  })  : _updateSettingsUseCase = updateSettingsUseCase,
        super(const SettingsState()) {
    _subscription = watchSettingsUseCase().listen(
      (settings) => emit(state.copyWith(settings: settings)),
    );
  }

  final UpdateSettingsUseCase _updateSettingsUseCase;
  late final StreamSubscription<AppSettings> _subscription;

  Future<void> setThemeMode(AppThemeMode mode) {
    return _updateSettingsUseCase(state.settings.copyWith(themeMode: mode));
  }

  Future<void> setCurrency(String currency) {
    return _updateSettingsUseCase(state.settings.copyWith(currency: currency));
  }

  Future<void> setPriceAlertsEnabled(bool enabled) {
    return _updateSettingsUseCase(state.settings.copyWith(priceAlertsEnabled: enabled));
  }

  Future<void> setMarketNewsEnabled(bool enabled) {
    return _updateSettingsUseCase(state.settings.copyWith(marketNewsEnabled: enabled));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
