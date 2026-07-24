import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

/// Root widget. Theme mode will read from Settings once that feature lands.
class CryptofolioApp extends StatelessWidget {
  const CryptofolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = sl<AuthBloc>();
    return BlocProvider.value(
      value: authBloc,
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
