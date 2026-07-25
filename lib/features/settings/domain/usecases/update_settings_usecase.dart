import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  UpdateSettingsUseCase(this._repository);
  final SettingsRepository _repository;

  Future<void> call(AppSettings settings) => _repository.updateSettings(settings);
}
