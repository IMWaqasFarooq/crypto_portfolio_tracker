import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/market/presentation/pages/coin_detail_page.dart';
import '../../features/market/presentation/pages/market_page.dart';
import '../../features/portfolio/presentation/pages/add_holding_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/portfolio/presentation/pages/portfolio_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/watchlist/presentation/pages/watchlist_page.dart';
import 'app_shell.dart';
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
          path: RoutePaths.coinDetail,
          name: RouteNames.coinDetail,
          builder: (context, state) => CoinDetailPage(coinId: state.pathParameters['coinId']!),
        ),
        GoRoute(
          path: RoutePaths.addHolding,
          name: RouteNames.addHolding,
          builder: (context, state) => const AddHoldingPage(),
        ),
        GoRoute(
          path: RoutePaths.notifications,
          name: RouteNames.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.market,
                builder: (context, state) => const MarketPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.portfolio,
                name: RouteNames.portfolio,
                builder: (context, state) => const PortfolioPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.watchlist,
                name: RouteNames.watchlist,
                builder: (context, state) => const WatchlistPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.settings,
                name: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ]),
          ],
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
