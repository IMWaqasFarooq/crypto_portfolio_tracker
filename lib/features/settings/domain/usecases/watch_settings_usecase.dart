import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class WatchSettingsUseCase {
  WatchSettingsUseCase(this._repository);
  final SettingsRepository _repository;

  Stream<AppSettings> call() => _repository.watchSettings();
}
