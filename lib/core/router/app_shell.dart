import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The bottom-nav shell hosting the four top-level tabs. Each branch keeps
/// its own navigation stack via [StatefulShellRoute.indexedStack], so
/// switching tabs preserves scroll position/state instead of rebuilding.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.pie_chart_rounded), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.star_border_rounded), label: 'Watchlist'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
