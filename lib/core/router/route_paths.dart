/// Centralized route path constants.
abstract final class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';

  static const home = '/';
  static const market = '/market';
  static const coinDetail = '/market/coin/:coinId';
  static const portfolio = '/portfolio';
  static const addHolding = '/portfolio/add';
  static const watchlist = '/watchlist';
  static const settings = '/settings';

  static String coinDetailPath(String coinId) => '/market/coin/$coinId';
}

abstract final class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const market = 'market';
  static const coinDetail = 'coinDetail';
  static const portfolio = 'portfolio';
  static const addHolding = 'addHolding';
  static const watchlist = 'watchlist';
  static const settings = 'settings';
}
