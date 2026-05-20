# jrr_f_bloc — Implementation Plan

Port the JRiver Remote client from Riverpod (`../jrr_f`) to `flutter_bloc`.
Everything else (Dio/Retrofit, GetIt, Drift, Freezed, fpdart, AutoRoute,
just_audio/audio_service, Talker, secure storage, shared_preferences) stays
identical.

Reference spec: `../spec.md` (v0.7.0).
Reference implementation: `../jrr_f/` (Riverpod, v2.7.0).

> **Superseded by `REFACTOR_PLAN.md` for state-management ownership.**
> This document captures the original Riverpod → BLoC port (Phases 0–11
> complete). The follow-up refactor in `REFACTOR_PLAN.md` retires the
> shared-state cubits/blocs listed in §6 in favour of GetIt-registered
> services with per-widget companion cubits (Phases 1–12 complete).
> Specifically retired: `SessionCubit`, `ZonesCubit`, `McwsPlayerBloc`,
> `LocalPlayerCubit`, `PlayerCubit`, `PlayerControllerCubit`, `QueueCubit`,
> `SearchByFileKeyCubit`, `FavoritesCubit`, `DownloadJobsCubit`,
> `DownloadedTracksCubit`. Their service equivalents live alongside the
> remaining widget-companion cubits — see `REFACTOR_PLAN.md` §5.

---

## 0. Architecture Rules (non-negotiable)

These three rules govern every widget and every cubit/bloc. Any deviation
is a refactor candidate.

1. **One cubit/bloc per stateful widget.** Every widget that owns business
   logic talks to exactly one cubit/bloc — never two or more. Widgets
   that compose other widgets are fine; each of those leaves still binds
   to its own single cubit/bloc.

2. **Widgets never touch services / repositories / APIs directly.** They
   read from and dispatch to their cubit/bloc only. `getIt<…Repository>()`,
   `Repository.method(...)`, and direct `Service.foo()` calls are
   disallowed from widget code. Cubits/blocs are the one place where
   side-effect dependencies get resolved.

3. **The cubit/bloc state surface is one immutable Freezed data class.**
   A widget's bloc exposes `state` (and `stream` for subscribers) —
   nothing else. The state is a `@freezed abstract class … with _$<Name>`
   (Freezed 3.x), giving free `==` / `hashCode` / `copyWith` and a single
   value-equal type for `BlocBuilder` diffs. No hand-written immutable
   wrappers, no public getters for "convenience" fields, no public
   streams, no public service references, no public mutable lists. All
   data the widget needs lives on the Freezed class; updates flow through
   `emit(newState)`. Tiny one-or-two-field shapes may use a Dart record
   typedef instead of Freezed (e.g. `typedef MiniPlayerState = ({PlayerStatus? status})`).

4. **Widget/cubit names are paired** — `SomeWidget` ↔ `SomeCubit` (or
   `SomeBloc`). Naming the cubit after what it does (`AuthGateCubit`,
   `SessionViewCubit`) hides the binding; naming it after its widget
   (`RootCubit`, `ServerSetupCubit`, `ArtworkCubit`, `LibraryCubit`)
   makes the one-to-one relationship obvious in imports and grep. Drop
   the trailing `Screen` / `Widget` / `Panel` / `Tile` suffix and append
   `Cubit` or `Bloc`. State classes follow the same root: `SomeState`.

5. **NEVER use the null assertion operator (`!`).** No `foo!`, no
   `bar!.baz`, no `map[key]!`. Null assertions trade a compile-time
   guarantee for a runtime crash and leak the assumption "this can't be
   null here" out of the type system, where the next refactor will
   silently invalidate it. Acceptable alternatives, in order of
   preference: (a) narrow with a local — `final x = nullable; if (x !=
   null) use(x);`; (b) pattern-match — `if (nullable case final x?)` or
   `switch (nullable) { final x? => …, null => … }`; (c) collection
   `?`-spreads — `[?maybe]`; (d) `??` for defaults; (e) tighten the type
   so the field is non-nullable in the first place. The negated type
   check `is!` is fine — that's not a null assertion.

These rules trade some keystrokes for tight blast-radius: any UI bug
points at exactly one cubit/bloc; any cubit/bloc test fakes one
dependency graph; refactors to the repository layer never reach widget
files. Cross-cutting non-widget state (e.g. `SessionService`,
`AndroidAutoSessionService`, the AudioHandler chain) lives outside the
bloc tree in plain services registered via GetIt and is observed via
`stream`/`state` getters — those services are consumed by blocs, not by
widgets directly.

---

## 1. Strategy

The codebase already separates **state** (Riverpod providers) from **data**
(repositories) and **transport** (MCWS clients). Only the providers layer is
rewritten. Repositories, models, MCWS client, parser, DB, DI, router, theme,
and widgets-minus-Consumers transfer 1:1.

Mapping rules:

- `NotifierProvider` / `AsyncNotifierProvider` with imperative methods →
  **Cubit** (state class + methods).
- Providers that react to streams or timers and need event ordering →
  **Bloc** (events + states).
- `Provider`/`FutureProvider` reads that are pure derivations → expose as
  Cubit getters or `select` on parent state. Do not invent a Cubit for
  read-only data.
- `ref.listen` cross-provider effects → `BlocListener` in the widget tree, or
  `bloc.stream.listen` wired in `main.dart` for non-UI orchestrators.

---

## 2. Dependencies (`pubspec.yaml`)

Copy `jrr_f/pubspec.yaml` verbatim with these swaps.

**Remove**

- `flutter_riverpod`
- `riverpod_annotation`
- `talker_riverpod_logger`
- `riverpod_generator`

**Add**

```yaml
flutter_bloc: ^9.1.0
bloc: ^9.0.0
bloc_concurrency: ^0.3.0     # transformers (droppable, restartable, sequential)
hydrated_bloc: ^10.0.0       # optional, only for LocalAudioQualityCubit
talker_bloc_logger: ^5.x     # replaces talker_riverpod_logger
```

```yaml
# dev_dependencies
bloc_test: ^10.0.0
```

**Keep**: `get_it`, `freezed`, `json_serializable`, `dio`, `retrofit`,
`drift`, `auto_route`, `fpdart`, `just_audio`, `audio_service`,
`shared_preferences`, `flutter_secure_storage`, `connectivity_plus`,
`share_plus`, `rxdart`, `mocktail`.

---

## 3. Folder Structure

Identical to `jrr_f/`, with `providers/` renamed to `bloc/` per feature.

```
lib/
  main.dart
  app.dart
  core/
    db/  di/  error/  layout/  lifecycle/  logging/
    network/  orientation/  router/  theme/
  features/
    connection/{data, bloc, widgets}
    favorites/{data, bloc, widgets}
    library/{data, bloc, widgets}
    offline/{data, services, bloc, widgets}
    player/{data, services, logging, bloc, widgets}
    queue/{data, bloc, widgets}
    zones/{data, services, bloc, widgets}
  shared/{extensions, widgets}
```

---

## 4. Core Layer — Copy as-is

These have zero Riverpod coupling. Port verbatim:

- `core/network/*` — `dio_factory.dart`, `mcws_api.dart` (+ `.g.dart`),
  `jriver_lookup_api.dart`, `mcws_client.dart`, `mcws_xml_parser.dart`,
  `ssl_trust.dart`, interceptors.
- `core/db/app_database.dart` (Drift).
- `core/error/app_exception.dart` (Freezed union).
- `core/logging/file_log_observer.dart`.
- `core/theme/*`, `core/layout/*`, `core/orientation/*`, `core/lifecycle/*`.

`core/router/`: keep AutoRoute. Replace `navigation_notifier.g.dart`
(Riverpod) with a `NavigationCubit` exposed via GetIt; the router reads it
directly or via `BlocBuilder` at the root.

---

## 5. Data Layer — Copy as-is

All `features/*/data/{models,repositories}` transfer unchanged. Repositories
return `Either<AppException, T>` via fpdart — that contract is
state-management agnostic.

---

## 6. BLoC Layer — Provider-by-Provider Mapping

| `jrr_f` provider | `jrr_f_bloc` replacement | Kind | Notes |
|---|---|---|---|
| `Session` | `SessionCubit` | Cubit | State = existing `SessionState` union. Methods: `restoreSilently`, `connect`, `enterOfflineMode`, `logout`. |
| `last_server_provider` | `LastServerCubit` | Cubit | Exposes `Option<SavedServer>`; reloads on `SessionCubit` changes via subscription. |
| `server_setup_provider` | `ServerSetupCubit` | Cubit | Form state (host/port/user/pass/useSsl/lookup result). |
| `favorites_provider` | `FavoritesCubit` | Cubit | CRUD on `FavoritesRepository`; emits `List<FavoriteItem>`. |
| `library_providers` (multiple) | `ArtistsCubit`, `ArtistAlbumsCubit`, `AlbumTracksCubit`, `SearchBloc`, `BrowseCubit`, `RandomAlbumsCubit`, `FolderTracksCubit` | Mixed | `SearchBloc` uses `bloc_concurrency.restartable` for debounce/cancel. Others are simple `AsyncState`-style cubits. |
| `mcws_player_provider` | `McwsPlayerBloc` | Bloc | Owns the 1s/5s `Playback/Info` polling timer. Events: `_Poll`, `Refresh`, `Pause`, `Resume`. Uses `PlayingNowChangeCounter` to gate queue refetch. |
| `local_player_provider` | `LocalPlayerBloc` | Bloc | Subscribes to `LocalPlayerService` streams (just_audio); maps to `LocalPlaybackState`. |
| `player_polling_provider` | merged into `McwsPlayerBloc` | — | Polling timer ownership moves inside the bloc. |
| `player_controller` | `PlayerControllerCubit` | Cubit | High-level commands (`playPause`, `next`, `seek`, `setVolume`) routing to MCWS or Local based on active zone. |
| `player_provider` | `PlayerCubit` (facade) | Cubit | Unified `PlayerStatus` view derived from `(McwsPlayerBloc, LocalPlayerBloc, ActiveZoneCubit)` via stream merge in constructor. |
| `local_audio_quality_provider` | `LocalAudioQualityCubit` (or `HydratedCubit`) | Cubit | Persists to SharedPreferences. |
| `queue_provider` | `QueueBloc` | Bloc | Watches change counter via injected `McwsPlayerBloc` stream; events: `Refresh`, `Move`, `Remove`, `Clear`, `PlayIndex`. |
| `zone_provider` | `ZonesCubit` | Cubit | Loads zone list + synthesizes Local zone. |
| `zone_polling_provider` | merged into `ZonesCubit` | — | 30s timer inside cubit. |
| `active_zone_provider` | `ActiveZoneCubit` | Cubit | Reads/persists `kActiveZoneGuidKey`; emits resolved `Zone`. |
| `download_jobs_provider` | `DownloadJobsBloc` | Bloc | Subscribes to `DownloadService.events`. |
| `download_status_provider` | `DownloadStatusCubit` | Cubit | Derived from `DownloadJobsBloc`. |
| `downloaded_tracks_provider` | `DownloadedTracksCubit` | Cubit | Wraps `DownloadsRepository`. |
| `navigation_notifier` | `NavigationCubit` | Cubit | Plain state-holder for current tab/route, consumed by AutoRoute guards. |

### BLoC conventions

- States: Freezed sealed unions (`Loading | Success | Error`) — same shape as
  current Riverpod `AsyncValue` usage so widgets switch over the union 1:1.
- Events for Blocs: Freezed sealed unions; never raw Dart records.
- One bloc per file; co-located `*_state.dart` and `*_event.dart` (for Blocs).
- Repositories injected via constructor; resolved through GetIt in factory
  functions used by `BlocProvider`.
- Side-effect-free `state`: every emission is an immutable copy. Use
  `copyWith`.

### Cross-bloc orchestration

Replace `ref.listen` / `ref.watch` patterns with:

1. **Construction-time subscription**: bloc's constructor subscribes to other
   blocs' streams (e.g. `PlayerCubit` listens to `ActiveZoneCubit.stream`).
   Cancel in `close()`.
2. **Widget-level `BlocListener`**: side effects bound to the route tree
   (e.g. logout → navigate to login).
3. **Top-level orchestrator** in `app.dart`: `MultiBlocListener` for app-wide
   effects (session change → reset player/queue/zones).

---

## 7. DI Changes (`core/di/injection.dart`)

The existing `configureDependencies()` registers Talker, AppDatabase, secure
storage, SharedPreferences, parser, and all repositories. Keep verbatim.

Add a `bloc_locator.dart` exposing factory functions for each bloc/cubit so
`BlocProvider(create: ...)` stays terse:

```dart
SessionCubit makeSessionCubit() =>
    SessionCubit(getIt(), getIt(), getIt(), getIt());
```

These factories live next to the bloc files; the locator is a thin re-export.

---

## 8. `main.dart` & `app.dart`

`main.dart` changes:

- Drop `ProviderScope` and `TalkerRiverpodObserver`.
- Set `Bloc.observer = TalkerBlocObserver(getIt<Talker>())` after
  `configureDependencies()`.
- Everything else (orientation lock, `FileLogObserver.init()`,
  `AudioService.init`, `LocalPlayerService` + `AndroidAutoPlayerService`
  setup, GetIt singletons, `FlutterError.onError`,
  `PlatformDispatcher.onError`) ports verbatim.

`app.dart`: wrap `MaterialApp.router` in a single `MultiBlocProvider`
exposing the long-lived top-level blocs (`SessionCubit`, `ActiveZoneCubit`,
`ZonesCubit`, `PlayerCubit`, `QueueBloc`, `DownloadJobsBloc`,
`FavoritesCubit`, `LocalAudioQualityCubit`, `NavigationCubit`).
Feature-scoped blocs (`ServerSetupCubit`, `SearchBloc`, `AlbumTracksCubit`,
etc.) are created at their route via `BlocProvider`.

---

## 9. Routing

Keep `auto_route` exactly as in `jrr_f/`. Only change: `NavigationCubit`
replaces the Riverpod notifier feeding route guards and tab state. Re-run
`build_runner` to regenerate `app_router.gr.dart` once the project is
reachable.

---

## 10. UI Layer (`features/*/widgets/*`)

Mechanical rewrite — same widget trees, different consumers.

| Riverpod | flutter_bloc |
|---|---|
| `ConsumerWidget` / `ConsumerStatefulWidget` | `StatelessWidget` / `StatefulWidget` |
| `ref.watch(provider)` | `context.watch<Bloc>().state` or `BlocBuilder` |
| `ref.read(provider.notifier).method()` | `context.read<Bloc>().method()` (cubit) or `.add(Event())` (bloc) |
| `ref.listen(provider, …)` | `BlocListener` |
| `AsyncValue.when(data:, loading:, error:)` | `switch` on the Freezed state union |

Use `BlocSelector` for the cases where Riverpod used `select` to avoid
rebuilds (e.g. mini-player reading only `state.positionMs`).

---

## 11. Codegen

```
dart run build_runner build --delete-conflicting-outputs
```

Generates: Freezed unions (states, events, models), JSON serializers,
Retrofit clients, AutoRoute. No Riverpod generator needed.

---

## 12. Testing

- Repository tests: mock `McwsApi` with mocktail — identical to `jrr_f`.
- Bloc tests: `bloc_test` package under `dev_dependencies`.
- Widget tests: wrap in `BlocProvider.value(value: MockBloc())` using
  mocktail's `MockBloc<Event, State>` / `MockCubit<State>`.

---

## 13. Implementation Phases

Bottom-up. Each phase ends with `flutter analyze && flutter test` clean and a
demoable milestone. Phases marked **vertical slice** include UI so the app
runs after that phase.

### Phase 0 — Scaffold (~½ day)

**Goal**: empty app builds and runs on iOS/Android/macOS.

- `pubspec.yaml`: copy from `jrr_f/`, swap Riverpod packages → bloc family
  per §2.
- `analysis_options.yaml`: copy from `jrr_f/`.
- Create folder skeleton per §3 (empty dirs / placeholder `.gitkeep`).
- `main.dart` minimal boot: `WidgetsFlutterBinding`, orientation lock,
  `MaterialApp(home: Scaffold(body: Text('jrr_f_bloc')))`.

**Deliverable**: `flutter run` shows a blank screen on every platform.

### Phase 1 — Core Infrastructure (1 day)

**Goal**: HTTP, DB, logging, error union ready; no UI yet.

- Port `core/network/*` (Dio, Retrofit clients, XML parser, SSL trust,
  interceptors).
- Port `core/db/app_database.dart` and run drift codegen.
- Port `core/error/app_exception.dart`.
- Port `core/logging/` (`FileLogObserver`) + add `TalkerBlocObserver`.
- Port `core/theme/`, `core/layout/`, `core/orientation/`, `core/lifecycle/`.
- Wire `core/di/injection.dart` (Talker, AppDatabase, SecureStorage,
  SharedPreferences, parser — repositories come later per phase).
- `main.dart`: install error handlers, `JRiverHttpOverrides`,
  `Bloc.observer`.

**Acceptance**: unit test that constructs `McwsApi` against a mock Dio
returns parsed `Alive` response.

### Phase 2 — Data Layer (1 day)

**Goal**: all repositories ported, tested in isolation.

- Port every `features/*/data/models/*.dart` + run freezed/json_serializable
  codegen.
- Port every `features/*/data/repositories/*.dart`. Register impls in
  `injection.dart`.
- Port `core/router/` (without `NavigationCubit` yet — stub for now).
- Repository tests with mocktail (mirror what exists in `jrr_f/test/`).

**Acceptance**: `flutter test` passes; repos return `Either<AppException,
T>` for representative happy/sad paths.

### Phase 3 — Connection Slice **(vertical slice)** (2 days)

**Goal**: log in to a real JRiver server, see the friendly name.

- `SessionCubit` + `SessionState` (Freezed union — already exists in
  `jrr_f`, port verbatim).
- `LastServerCubit`, `ServerSetupCubit`.
- Port screens: `connecting_screen`, `server_manager_screen`,
  `server_setup_screen` (swap Consumer→Bloc patterns per §10).
- Access-key lookup path (`JRiverLookupApi`).
- AutoRoute wiring with a temporary post-login placeholder.
- `app.dart`: `MultiBlocProvider` at root for session-scoped blocs.

**Acceptance**: launch app → enter credentials or access key → land on a
placeholder showing `ServerInfo.name`. Silent reconnect works on relaunch.
Logout returns to login screen.

### Phase 4 — Zones (1 day)

**Goal**: list zones, pick active one, including synthesized Local zone.

- `ZonesCubit` with 30s polling timer; synthesize Local zone (§4.13).
- `ActiveZoneCubit` (persist `kActiveZoneGuidKey`).
- Port `zone_list_screen`, `zone_tile`.

**Acceptance**: zones list refreshes; selecting a zone updates persisted
GUID; Local zone is appended and selectable.

### Phase 5 — Player **(vertical slice)** (3 days)

**Goal**: see now-playing, control transport, both MCWS and Local zones.

- `McwsPlayerBloc` — owns `Playback/Info` polling (1s playing / 5s idle
  per §5.1). Pauses when active zone is Local or app is backgrounded.
- `LocalPlayerBloc` — subscribes to `LocalPlayerService` (just_audio).
- `PlayerCubit` facade — `CombineLatestStream` of
  `(McwsPlayerBloc, LocalPlayerBloc, ActiveZoneCubit)`.
- `PlayerControllerCubit` — routes commands to MCWS or Local based on
  active zone.
- `LocalAudioQualityCubit`.
- Port screens: `now_playing_screen`, `mini_player_panel`.
- Wire `audio_service` in `main.dart` (port verbatim from `jrr_f`).

**Acceptance**: play/pause/seek/volume work against MCWS zone; switching to
Local zone streams via `File/GetFile`; mini-player tracks position; lock
screen controls work on iOS/Android.

### Phase 6 — Queue (1 day)

**Goal**: view and edit Playing Now.

- `QueueBloc` — refresh on `PlayingNowChangeCounter` change (subscribes to
  `McwsPlayerBloc.stream`).
- Events: `Refresh`, `Move`, `Remove`, `Clear`, `PlayIndex`.
- Port `queue_screen`, `queue_item_tile`.

**Acceptance**: queue reflects server state, edits round-trip; reorder/
remove/clear all work.

### Phase 7 — Library (2 days)

**Goal**: browse and search the music library.

- `ArtistsCubit`, `ArtistAlbumsCubit`, `AlbumTracksCubit`, `BrowseCubit`,
  `FolderTracksCubit`, `RandomAlbumsCubit`.
- `SearchBloc` with `bloc_concurrency.restartable` for debounce/cancel.
- Multi-disc grouping (`AlbumGroup`, §4.17).
- Port all `features/library/widgets/*` screens.
- `library_action_sheet` (Play / Play next / Add to playing now) — single
  pattern per §9.16.

**Acceptance**: artist→albums→tracks navigation works; multi-disc albums
render with disc headers; search debounces and cancels in-flight requests.

### Phase 8 — Favorites + Offline (2 days)

**Goal**: favorite browse nodes; download and play offline.

- `FavoritesCubit` (browse-node favorites).
- `DownloadJobsBloc` subscribes to `DownloadService.events`.
- `DownloadStatusCubit`, `DownloadedTracksCubit`.
- Port screens: `favorites_screen`, `downloaded_albums_screen`,
  `downloaded_artists_screen`, `downloaded_album_detail_screen`,
  download progress indicators, confirm-delete dialog.
- Offline Mode session path (synthetic `ServerInfo.offline`, §2.5/§2.6).

**Acceptance**: download an album → kill server → relaunch → enter Offline
Mode → play downloaded tracks via Local zone.

### Phase 9 — Router & Navigation Polish (½ day)

**Goal**: deep links, guards, tab state.

- `NavigationCubit` replaces Riverpod `navigation_notifier`.
- AutoRoute guards consult `SessionCubit`.
- Re-run `build_runner` for final `app_router.gr.dart`.

**Acceptance**: deep link to a track works while authenticated; redirects to
login when unauthenticated; tab state persists across navigation.

### Phase 10 — Android Auto (1 day, Android only)

**Goal**: car head-unit can browse and play.

- Port `JrrAudioHandler`, `AndroidAutoPlayerService`,
  `AndroidAutoSessionService`, `MediaItemMapper`, `VoiceIntentResolver`,
  `RecentlyPlayedRepository`.
- Verify `getChildren` browse tree + recents.

**Acceptance**: Android Auto DHU shows Browse / Recent / Favorites and plays
selected items.

### Phase 11 — Hardening & Release Prep (1 day)

- `dart fix --apply`, `dart format .`, `flutter analyze` clean.
- All `bloc_test` suites green.
- `flutter_launcher_icons` configured (copy from `jrr_f/pubspec.yaml`).
- Smoke-test on iOS, Android, macOS, Windows, Linux.
- Verify Token redaction in logs (§14).
- Tag `v1.0.0-bloc`.

---

### Timeline summary

| Phase | Title                              | Effort      | Vertical slice |
|-------|------------------------------------|-------------|----------------|
| 0     | Scaffold                           | ½ day       |                |
| 1     | Core Infrastructure                | 1 day       |                |
| 2     | Data Layer                         | 1 day       |                |
| 3     | Connection Slice                   | 2 days      | ✓              |
| 4     | Zones                              | 1 day       |                |
| 5     | Player                             | 3 days      | ✓              |
| 6     | Queue                              | 1 day       |                |
| 7     | Library                            | 2 days      |                |
| 8     | Favorites + Offline                | 2 days      |                |
| 9     | Router & Navigation Polish         | ½ day       |                |
| 10    | Android Auto                       | 1 day       |                |
| 11    | Hardening & Release Prep           | 1 day       |                |
| **Total** |                                | **~16 days** |               |

Effort assumes one engineer familiar with both Riverpod and bloc, with
`jrr_f/` open for reference.

---

## 14. Risk Notes

- **Stream lifetime**: any bloc that subscribes to another bloc's `stream`
  must cancel in `close()` — easy to leak. Pattern: store
  `StreamSubscription` field; cancel before `super.close()`.
- **Polling under app lifecycle**: `McwsPlayerBloc` and `ZonesCubit` listen
  to `AppLifecycleListener` (already in `core/lifecycle/`); pause/resume
  timers there rather than via Riverpod's `keepAlive`.
- **`PlayerCubit` facade**: state derived from three sources. Use
  `rxdart.CombineLatestStream` (already a dependency) inside the cubit to
  keep derivation explicit and testable.
- **HydratedBloc opt-in**: only worth it for `LocalAudioQualityCubit`.
  Don't blanket-apply it — most state should reset on logout.
- **Token redaction in logs**: `TalkerBlocObserver` will log every state
  emission. Ensure `SessionState.authenticated` and any state carrying a
  token override `toString()` to redact (matches spec §9.13).
