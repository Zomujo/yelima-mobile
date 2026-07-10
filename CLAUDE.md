# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Yelima is a Flutter health-tracking app (medications, vitals, appointments, AI chat) with an offline-first
local database backed by remote sync. Backend is a REST API (Dio) plus Firebase (Auth, Firestore, Messaging,
Crashlytics, Analytics).

## Common commands

```bash
flutter pub get                         # install dependencies

# Run (three flavors: dev, staging, prod — dev/prod have dedicated entrypoints and .env files)
flutter run -t lib/main_dev.dart --flavor dev
flutter run -t lib/main_prod.dart --flavor prod

# Tests
flutter test                                    # full suite
flutter test test/features/progress/data/repositories/progress_repository_impl_test.dart   # single file
flutter test --plain-name "should return cached data when offline"                          # single test by name

# Lint / static analysis
flutter analyze

# Code generation (required after touching Drift tables/DAOs, Freezed entities, or json_serializable models)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating
```

`.env`, `.env.dev`, `.env.prod` hold `API_BASE_URL` and are loaded via `flutter_dotenv` in `main_dev.dart` /
`main_prod.dart`; `main.dart` (prod, no dotenv) hardcodes the API URL instead. Android flavors are declared in
`android/app/build.gradle` (`flavorDimensions`/`productFlavors`) and must stay in sync with the Dart entrypoints.

CI (`.github/workflows/staging.yml`) runs `flutter pub get` + `flutter test` on push to `staging`.

## Architecture

### Layering (clean architecture per feature)

Each module under `lib/features/<name>/` follows:

```
data/
  datasources/     # remote (Dio via APIClient) and sometimes local (Drift) sources
  models/          # DTOs — parse remote JSON, convert to/from domain entities
  repositories/    # implements the domain repository interface; owns online/offline branching
domain/
  entities/        # plain domain objects (often Freezed)
  repositories/     # abstract interfaces consumed by controllers
  usecases/        # optional, only where business logic warrants extraction (e.g. home)
presentation/
  controllers/     # ChangeNotifier controllers (Provider), one per screen/feature slice
  screens/, widgets/
```

Each feature that needs DI exposes an `*_injection.dart` (see `features/auth/auth_injection.dart`) registered
from the central `lib/injection_container.dart` (GetIt, `sl`). Simpler features register directly inline in
`injection_container.dart` instead of a separate injection file — follow whichever pattern the feature already
uses.

### Offline-first data flow

Repositories are the only layer that knows about connectivity. The standard pattern (see
`features/medications/data/repositories/medication_repository_impl.dart`,
`features/progress/data/repositories/progress_repository_impl.dart`):

1. Check `INetworkInfo.isConnected`.
2. If online: call the remote datasource, then cache the result into Drift (`AppDatabase`) before returning it.
3. If offline (or the remote call throws): fall back to reading the cached value from Drift.
4. Mutations made while offline are written to the `PendingMutations` table instead of failing, then replayed
   once connectivity returns.

There are two independent mechanisms that replay queued mutations — `SyncService`
(`lib/core/services/sync_service.dart`) and `MutationSyncManager` (`lib/core/services/mutation_sync_manager.dart`).
Both drain `AppDatabase.pendingMutationsDao`, both drop a mutation after 3 failed retries ("poison pill"), but
`MutationSyncManager` is the newer generic version driven by an `IRemoteMutationSource` per entity type
(registered per-feature in `injection_container.dart`), while `SyncService` hardcodes medication/chat handling.
When wiring a new offline-first feature, prefer implementing `IRemoteMutationSource` and registering it with
`MutationSyncManager` rather than extending `SyncService`. A separate `DeletionSyncManager` handles queued
deletions (`PendingDeletions` table) the same way.

Local persistence is a single Drift database (`lib/core/db/app_database.dart`), one `AppDatabase` singleton
shared by all features' DAOs. Schema changes require bumping `schemaVersion` and adding a branch to
`MigrationStrategy.onUpgrade` — never edit an existing migration step once it has shipped.

### Session lifecycle

`SessionLifecycleService` (`lib/core/services/session_lifecycle_service.dart`) coordinates startup/teardown
across features on sign-in/sign-out. Services implement `SessionLifecycleHandler` and register themselves with
a numeric `priority` (lower runs first on session start, and — because the group order is reversed — last on
session end). Registration happens at construction time in `injection_container.dart` via the `..also((s) =>
sl<SessionLifecycleService>().register(s, priority: N)))` pattern; check existing priorities before picking one
for a new handler so init/teardown ordering stays correct (e.g. `DatabaseLifecycleHandler` at 10 must run before
things that depend on the DB being ready).

### Networking

All REST calls go through the single `APIClient` (`lib/core/api/api_client.dart`), a thin Dio wrapper with three
interceptors: `LoggingInterceptor`, `AuthInterceptor` (attaches bearer token via `TokenManager`), and
`ErrorInterceptor`. Datasources call `APIClient` methods and throw `ApiException` (via
`ApiException.fromDioError`) on failure; repositories catch `ApiException` and convert to `Failure` subtypes
(`ServerFailure`, `CacheFailure`, `NetworkFailure`, etc. in `lib/core/exceptions/exceptions.dart`) wrapped in
`fpdart`'s `Either`. There is also a separate, older `ErrorException` hierarchy (`NetworkException`,
`UnauthenticatedException`, ...) used by `ExceptionWrapper.runAsync`, primarily around Firebase-auth-adjacent
flows — the two error-handling styles coexist by area of the code rather than one having fully replaced the
other.

### Routing and app shell

`go_router` config lives in `lib/core/router/router.dart`. A single `redirect` callback drives all auth/
registration/splash gating using `AuthController` state (`isInitialized`, `isAuthenticated`,
`isInitialSyncInProgress`, `userEntity.registrationStatus`) — new routes that need auth gating don't need their
own guard, just correct placement relative to the existing `isAuthRoute`/`isRegistrationRoute` checks. Bottom-nav
screens (home, chat, reading logging, appointments, profile) sit inside a `ShellRoute` wrapped in
`MainScaffold`; everything else (auth, settings, edit profile, medications, progress, AI chat) is a top-level
route pushed over the shell.

### State management

Feature state is `ChangeNotifier`-based controllers provided via `provider`, instantiated through GetIt
(`sl<XController>()`) and wired into `MultiProvider` in `lib/app.dart`. Controllers are constructed there for
anything the app shell needs at startup (auth, home metrics, medications, appointments); screen-local controllers
that aren't needed globally are provided closer to their screen instead.

### Environment/config

`AppConfig.instance` (`lib/core/config/app_config.dart`) is a `static late` singleton set once in `main.dart`/
`main_dev.dart`/`main_prod.dart` before `bootstrap()` runs, and read everywhere else (`AppConfig.instance.flavor`,
`.apiBaseUrl`, `.isDebugMode`, ...). `bootstrap.dart` is the single shared startup path: Firebase init,
Crashlytics/Analytics hookup, notification permission request, global error handlers, then `di.init()`
(GetIt) before `runApp`.
