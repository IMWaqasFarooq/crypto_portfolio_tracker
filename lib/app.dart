import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'features/watchlist/presentation/cubit/watchlist_cubit.dart';

class CryptofolioApp extends StatelessWidget {
  const CryptofolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = sl<AuthBloc>();
    // Built once per app lifetime - recreating it inside the theme BlocBuilder
    // below would reset navigation state on every theme change.
    final router = AppRouter.build(authBloc: authBloc);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: sl<WatchlistCubit>()),
        BlocProvider.value(value: sl<PortfolioCubit>()),
        BlocProvider.value(value: sl<SettingsCubit>()),
        BlocProvider.value(value: sl<NotificationsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) => previous.settings.themeMode != current.settings.themeMode,
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Cryptofolio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _toThemeMode(state.settings.themeMode),
            routerConfig: router,
          );
        },
      ),
    );
  }

  ThemeMode _toThemeMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
