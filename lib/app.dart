import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'features/watchlist/presentation/cubit/watchlist_cubit.dart';

/// Root widget. Theme mode will read from Settings once that feature lands.
class CryptofolioApp extends StatelessWidget {
  const CryptofolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = sl<AuthBloc>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: sl<WatchlistCubit>()),
        BlocProvider.value(value: sl<PortfolioCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Cryptofolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.build(authBloc: authBloc),
      ),
    );
  }
}
