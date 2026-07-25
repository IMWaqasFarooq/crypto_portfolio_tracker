import 'package:equatable/equatable.dart';

import '../../domain/entities/app_settings.dart';

class SettingsState extends Equatable {
  const SettingsState({this.settings = AppSettings.defaults});
  final AppSettings settings;

  SettingsState copyWith({AppSettings? settings}) => SettingsState(settings: settings ?? this.settings);

  @override
  List<Object?> get props => [settings];
}
