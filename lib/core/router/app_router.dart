import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_event.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import 'go_router_refresh_stream.dart';
import 'route_paths.dart';

abstract final class AppRouter {
  static GoRouter build({required AuthBloc authBloc}) {
    return GoRouter(
      initialLocation: RoutePaths.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) => _redirect(authBloc.state, state.matchedLocation),
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.market,
          builder: (context, state) => const _HomePlaceholder(),
        ),
      ],
    );
  }

  static String? _redirect(AuthState authState, String location) {
    final atSplash = location == RoutePaths.splash;
    final atLogin = location == RoutePaths.login;

    return switch (authState) {
      AuthInitial() || AuthAuthenticating() => atSplash ? null : RoutePaths.splash,
      AuthAuthenticated() => (atLogin || atSplash) ? RoutePaths.home : null,
      AuthUnauthenticated() => atLogin ? null : RoutePaths.login,
    };
  }
}

/// Replaced by the real tabbed shell (market/portfolio/watchlist/settings) in Phase 3+.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cryptofolio')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.read<AuthBloc>().add(const AuthEvent.logoutRequested()),
          child: const Text('Log out'),
        ),
      ),
    );
  }
}
