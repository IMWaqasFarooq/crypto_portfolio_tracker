import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);
  final SettingsLocalDataSource _localDataSource;

  @override
  Stream<AppSettings> watchSettings() => _localDataSource.watchSettings();

  @override
  Future<void> updateSettings(AppSettings settings) => _localDataSource.updateSettings(settings);
}
