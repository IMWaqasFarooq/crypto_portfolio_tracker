import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/currency_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SectionHeader('Appearance'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (selection) => cubit.setThemeMode(selection.first),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader('Currency'),
              Card(
                child: DropdownButtonHideUnderline(
                  child: ListTile(
                    title: const Text('Display currency'),
                    trailing: DropdownButton<String>(
                      value: settings.currency,
                      items: supportedCurrencies
                          .map((code) => DropdownMenuItem(value: code, child: Text(code.toUpperCase())))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) cubit.setCurrency(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader('Notifications'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Price alerts'),
                      subtitle: const Text('Get notified when your watchlist coins move'),
                      value: settings.priceAlertsEnabled,
                      onChanged: cubit.setPriceAlertsEnabled,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Market news'),
                      subtitle: const Text('Occasional updates on major market moves'),
                      value: settings.marketNewsEnabled,
                      onChanged: cubit.setMarketNewsEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.tonalIcon(
                onPressed: () => context.read<AuthBloc>().add(const AuthEvent.logoutRequested()),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log out'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
