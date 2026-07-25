import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

class AppSettings extends Equatable {
  const AppSettings({
    required this.themeMode,
    required this.currency,
    required this.priceAlertsEnabled,
    required this.marketNewsEnabled,
  });

  static const defaults = AppSettings(
    themeMode: AppThemeMode.system,
    currency: 'usd',
    priceAlertsEnabled: true,
    marketNewsEnabled: true,
  );

  final AppThemeMode themeMode;
  final String currency;
  final bool priceAlertsEnabled;
  final bool marketNewsEnabled;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? currency,
    bool? priceAlertsEnabled,
    bool? marketNewsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled,
      marketNewsEnabled: marketNewsEnabled ?? this.marketNewsEnabled,
    );
  }

  @override
  List<Object?> get props => [themeMode, currency, priceAlertsEnabled, marketNewsEnabled];
}
