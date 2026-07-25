# Cryptofolio

A cryptocurrency portfolio & market tracker built with Flutter, showcasing production-grade
mobile architecture: feature-first Clean Architecture, BLoC state management, real-time price
streaming, offline-first caching, and full Firebase observability.

Live market data comes from the [CoinGecko](https://www.coingecko.com/en/api) REST API; live
price ticks stream over a public [Binance](https://binance-docs.github.io/apidocs/spot/en/#websocket-market-streams)
WebSocket.

## Features

- **Authentication** — email/password sign-in against a mock backend, session persisted in the
  platform Keychain/Keystore via `flutter_secure_storage`, silent auto-login on relaunch.
- **Market** — paginated, searchable coin list with live-streamed prices, pull-to-refresh, and a
  coin detail screen with a line/candlestick chart toggle across multiple timeframes.
- **Portfolio** — track holdings with live P&L, allocation breakdown, and a value-over-time chart
  approximated from each held coin's price history.
- **Watchlist** — star coins from anywhere in the app; live-updating list backed by Hive.
- **Notifications** — Firebase Cloud Messaging + local notifications, with an in-app inbox for
  price alerts and market news.
- **Settings** — theme (light/dark/system), display currency, and notification preferences,
  reactive across the whole app.

## Architecture

Each feature is a self-contained vertical slice with its own `data` / `domain` / `presentation`
layers, isolated by feature so any one of them could be pulled out or worked on independently.
Cross-feature concerns (networking, DI, error handling, storage, theming) live in `core`.

```mermaid
flowchart TB
    subgraph Presentation
        UI["Widgets / Pages"]
        Bloc["Bloc / Cubit"]
        UI <--> Bloc
    end
    subgraph Domain
        UseCase["Use Cases"]
        Entity["Entities"]
        RepoIface["Repository (abstract)"]
        UseCase --> RepoIface
    end
    subgraph Data
        RepoImpl["Repository (impl)"]
        Remote["Remote DataSource\n(Dio -> CoinGecko / Binance WS)"]
        Local["Local DataSource\n(Hive cache)"]
        RepoImpl --> Remote
        RepoImpl --> Local
    end
    Bloc --> UseCase
    RepoIface -.implemented by.-> RepoImpl

    style Presentation fill:#1f6feb22,stroke:#1f6feb
    style Domain fill:#3fb95022,stroke:#3fb950
    style Data fill:#db61a222,stroke:#db61a2
```

The domain layer only depends on abstractions (`RepositoryIface`), never on `data`, so use cases
and blocs are unit-testable with a mocked repository and no Flutter/platform dependency at all.

**Error handling** flows uniformly through the stack as `Either<Failure, T>` (via `dartz`):
data sources throw typed exceptions, a repository maps them to a sealed `Failure` union, and the
presentation layer pattern-matches on `Failure` to render network/server/cache/validation-specific
UI (see `core/error` and `core/widgets/error_state_view.dart`).

**Real-time prices**: REST (CoinGecko) provides the authoritative snapshot; a shared Binance
WebSocket stream (owned by the Market feature) pushes live ticks that patch
`currentPrice`/`priceChangePercentage24h` on top of that snapshot in Market, Coin Detail,
Portfolio, and Watchlist simultaneously, deduplicated behind one connection with per-screen
subscribe/unsubscribe reference counting.

**Dependency injection** is a plain `GetIt` service locator, wired feature-by-feature — each
feature exposes a `registerXFeature(GetIt sl)` function called once from
`core/di/injection_container.dart` at startup.

## Tech stack

| Concern | Choice | Why |
|---|---|---|
| State management | `flutter_bloc` (Bloc + Cubit) | Explicit, testable state transitions; Bloc for multi-event flows (Market, Auth), Cubit for simpler single-purpose state (Portfolio, Settings) |
| Immutable models | `freezed` | Sealed unions for events/state/failures, generated `copyWith`/equality |
| DI | `get_it` | Minimal, no code generation required, fast to reason about |
| Networking | `dio` | Interceptor pipeline (auth, retry with backoff, error normalization, dev logging) |
| Local persistence | `hive` | Lightweight, fast, no native SQL dependency, works well for cache + settings + notification history |
| Functional error handling | `dartz` (`Either`) | Forces every call site to handle failure explicitly, no silent exceptions crossing layers |
| Routing | `go_router` | Declarative, deep-link-ready, `StatefulShellRoute` gives the bottom-nav tabs independent navigation stacks |
| Charts | `fl_chart` (line) + `candlesticks` (OHLC) | `fl_chart` has no native candlestick series |
| Realtime | raw `web_socket_channel` to Binance | CoinGecko has no free streaming tier; Binance's public ticker stream is free and keyless |
| Observability | Firebase Crashlytics + Analytics + Messaging | Crash reporting, usage analytics, and push notifications behind swappable interfaces so tests/dev builds can no-op them |

## Project structure

```
lib/
  core/                   # Shared across every feature
    config/               # Flavors, env loading
    di/                   # GetIt bootstrap
    error/                # Failure union, exception mapping
    network/              # Dio client + interceptors
    router/                # go_router config, app shell
    services/              # Analytics/crash reporting interfaces, CurrencyProvider
    storage/                # Hive box registry, secure token storage
    theme/                  # Material 3 theme, spacing/text-style scales
    widgets/                # Shared empty/error/skeleton state views
  features/
    authentication/
    market/
    portfolio/
    watchlist/
    notifications/
    settings/
      data/                 # Models, local/remote data sources, repository impl
      domain/               # Entities, repository interface, use cases
      presentation/         # Bloc/Cubit, pages, widgets
test/                      # Unit + widget tests, mirrors lib/ structure
integration_test/          # End-to-end flows driven on a real device/simulator
```

## Getting started

### Prerequisites

- Flutter 3.9+ (Dart 3.12+)
- An iOS simulator or Android emulator/device
- A [Firebase](https://firebase.google.com) project (for Crashlytics/Analytics/Messaging) — the
  app runs fine without one too, falling back to no-op observability services

### Setup

```bash
git clone <this-repo>
cd crypto_portfolio_tracker
flutter pub get

# Environment config
cp assets/env/.env.example assets/env/.env.development
cp assets/env/.env.example assets/env/.env.production
# CoinGecko's free tier needs no API key - the defaults work out of the box.

# Firebase (optional - skip to run with no-op analytics/crashlytics/notifications)
dart pub global activate flutterfire_cli
flutterfire configure

# Generate freezed/json_serializable code
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run -t lib/main_development.dart   # development flavor
flutter run -t lib/main_production.dart    # production flavor
```

## Testing

```bash
flutter test                                                # unit + widget tests
flutter test integration_test/<file>.dart -d <device-id>    # a single e2e flow
```

Integration tests are written against `IntegrationTestWidgetsFlutterBinding` and exercise real
navigation, real Hive storage, and the real CoinGecko API (no mocking) — they're driven on an
iOS simulator/Android emulator rather than headless, since the app's live-price streaming and
platform Keychain integration aren't meaningfully testable in a browser environment.

## Future improvements

- Push a real backend behind Authentication instead of the mock data source
- Cost-basis-aware portfolio history (currently approximates value-over-time using *current*
  holdings against historical prices, not a true per-lot ledger)
- Widget/golden-image tests for chart rendering
- CI pipeline (analyze, test, build) on PR
