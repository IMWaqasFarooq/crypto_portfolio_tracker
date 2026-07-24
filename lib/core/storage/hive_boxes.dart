/// Names of every Hive box in the app.
abstract final class HiveBoxes {
  static const market = 'market_box';
  static const portfolio = 'portfolio_box';
  static const watchlist = 'watchlist_box';
  static const settings = 'settings_box';
}

/// Reserved typeIds: 0 CachedCoinModel, 1 CachedPricePointModel, 2 HoldingModel, 3 WatchlistItemModel, 4 AppSettingsModel.
abstract final class HiveTypeIds {
  static const cachedCoin = 0;
  static const cachedPricePoint = 1;
  static const holding = 2;
  static const watchlistItem = 3;
  static const appSettings = 4;
}
