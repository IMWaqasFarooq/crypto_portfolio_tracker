import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

/// Placeholder shell, replaced with the real route graph once auth/home land.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.market,
        builder: (context, state) => const _BootstrapPlaceholder(),
      ),
    ],
  );
}

class _BootstrapPlaceholder extends StatelessWidget {
  const _BootstrapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Cryptofolio - core layer bootstrapped')),
    );
  }
}
