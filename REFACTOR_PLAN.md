# Refactor Plan — Cubits/Blocs → Services + Widget Companion Cubits

Drive every cubit/bloc with cross-widget state into a `Service` registered
in GetIt, and bind each widget to exactly one paired companion cubit.
Implements the four Architecture Rules in `PLAN.md` §0:

1. One cubit/bloc per widget with business logic.
2. Widgets never touch services / repositories / APIs directly.
3. Cubits expose one immutable state object — no extra public getters,
   streams, or "convenience" properties.
4. Widget/cubit names are paired (`SomeWidget` ↔ `SomeCubit`).

Today `SessionService` and `ActiveZoneService` already follow the pattern;
the cubits listed below are next.

---

## 1. In Scope

Cubits to retire by replacing with services:

- `ZonesCubit` → `ZonesService`
- `McwsPlayerBloc` → `McwsPlayerService`
- `LocalPlayerCubit` → `LocalPlaybackService` (kept distinct from the
  existing `LocalPlayerService` audio_service handler)
- `PlayerCubit` → `PlayerService` (facade routing MCWS ↔ Local)
- `QueueCubit` → `QueueService`
- `SearchByFileKeyCubit` → `TrackLookupService`
- `FavoritesCubit` → `FavoritesService`
- `DownloadJobsCubit` → `DownloadJobsService`
- `DownloadedTracksCubit` → `DownloadedTracksService`
- `PlayerControllerCubit` → `PlayerCommandService` (action sink, not
  state)

Untouched / out of scope:

- `LocalAudioQualityCubit` — already a thin form-style cubit; pair it
  with its consumer widget instead (no service needed). Out of scope for
  this pass.
- `LibraryChromeCubit` — pure UI state, stays.
- `NavigationCubit` — top-level shell state, stays.
- `BrowseNavigationCubit` — per-tab nav stack, stays.
- All `LibAsync<T>` library cubits (`ArtistsCubit`, `RandomAlbumsCubit`,
  `SearchBloc`, `BrowseChildrenCubit`, etc.) — they're per-screen
  request/response containers; they already follow rule 3 and bind to
  their respective tab widget. Stay.
- `SessionService`, `ActiveZoneService` — already done.

---

## 2. Architectural Shape

For every conversion the pattern is identical:

```dart
// lib/features/<feature>/<feature>_service.dart
class SomeService {
  SomeState get state;
  Stream<SomeState> get stream;
  // action methods, returning Future<void> or Future<AppException?>
}
```

- Single broadcast `StreamController<SomeState>` + private `_state`
  field.
- `_emit(next)` only if `state != next` (no spurious rebuilds).
- Registered in `core/di/injection.dart` with `getIt.registerSingleton`.
- Consumed by other services / blocs via `getIt<SomeService>()`.
- Consumed by widgets **only** through a paired companion cubit.

Each widget that needs to observe one or more services owns a paired
cubit named after the widget:

```dart
class SomeWidgetCubit extends Cubit<SomeWidgetState> {
  SomeWidgetCubit({required FooService foo, required BarService bar}) {
    _fooSub = foo.stream.listen((_) => _recompute());
    _barSub = bar.stream.listen((_) => _recompute());
    _recompute();
  }
  void _recompute() {
    final next = SomeWidgetState(...);
    if (state != next) emit(next);
  }
}
```

The cubit emits exactly one immutable state class. Action methods
delegate straight to the underlying service(s).

---

## 3. Service Interfaces

### 3.1 `ZonesService`

State: `ZonesState` (already exists as a Freezed union) — moved out of
`bloc/`.
Action surface:
- `Future<void> refresh()`
- `void pause()` / `void resume()` (lifecycle hooks)

Dependencies: `ZoneRepository`, `SessionService`, `ActiveZoneService`,
`Talker`. Owns the 30 s polling timer.

### 3.2 `McwsPlayerService`

State: `PlayerSnapshot`.
Implements `PlayerController` (same surface as today).
Owns adaptive `Playback/Info` polling (1 s playing / 5 s idle).

Dependencies: `PlayerRepository`, `LibraryRepository`, `SessionService`,
`ActiveZoneService`, `Talker`.

### 3.3 `LocalPlaybackService`

State: `PlayerSnapshot`.
Implements `PlayerController`.
Owns just_audio stream subscriptions, per-zone queue load/save,
downloads-set listener, AA handler swap.

Dependencies: `LocalPlayerService` (audio_service handler — unchanged
name to avoid breaking audio_service.init wiring), `ActiveZoneService`,
`LocalQueueRepository`, `DownloadsRepository` (or
`DownloadedTracksService` once available — see §4 order), `Talker`,
`SharedPreferences`, optional `JrrAudioHandler` + `AndroidAutoPlayerService`
(resolved via getIt when registered).

### 3.4 `PlayerService`

State: `PlayerSnapshot`.
Facade routing snapshots from `McwsPlayerService` or
`LocalPlaybackService` based on `ActiveZoneService.state`.

Dependencies: `McwsPlayerService`, `LocalPlaybackService`,
`ActiveZoneService`.

### 3.5 `QueueService`

State: `QueueState` (Freezed union).
Action surface: `refresh()`, `removeItem(int)`, `moveItem(int, int)`,
`clearQueue()`.

Dependencies: `QueueRepository`, `LocalPlayerService`,
`LocalPlaybackService`, `ActiveZoneService`, `PlayerService`, `Talker`.

### 3.6 `TrackLookupService`

State: `Track?` (or a lightweight wrapper).
Action: `Future<void> lookup(int fileKey)`.

Dependencies: `LibraryRepository`.

### 3.7 `FavoritesService`

State: `List<BrowseItem>`.
Action: `Future<void> toggle(BrowseItem)`, `Future<void> reload()`.

Dependencies: `FavoritesRepository`.

### 3.8 `DownloadJobsService` / `DownloadedTracksService`

State: `List<DownloadJob>` / `List<DownloadedTrack>`.
Both are pure stream pipes; no actions of their own — the existing
`DownloadsRepository` already exposes mutating methods (`enqueue`,
`cancel`, `delete`, etc.). The services exist so widgets observe state
through services, never the repo.

Dependencies: `DownloadsRepository`.

### 3.9 `PlayerCommandService`

Not a state holder. Has no `state` / `stream` — it's a command sink.
Action methods: every `PlayerController` member, routed to the
appropriate sub-service via `ActiveZoneService`.

Dependencies: `McwsPlayerService`, `LocalPlaybackService`,
`ActiveZoneService`.

Note: `PlayerCommandService` is an exception to "services emit state."
It models a command interface. Widgets that issue commands (transport
buttons, popup actions) still go through their **companion cubit**,
which forwards to `PlayerCommandService`. Widgets do not call this
service directly.

---

## 4. Phases

Bottom-up by dependency graph. Every phase:

- Ends with `flutter analyze` clean and `flutter test` green.
- Ships a manual smoke-test of the affected screens.
- Deletes the original cubit/bloc once nothing references it.
- Is one commit.

Effort estimates assume one engineer familiar with the codebase.

### Phase 1 — `TrackLookupService` (½ day) — ✅ done

**Goal.** Retire `SearchByFileKeyCubit`. The Now Playing header
enrichment goes through a service instead.

**Deliverables.**
- `lib/features/library/track_lookup_service.dart` + register in DI.
- `bloc/search_by_file_key_cubit.dart` deleted.
- `NowPlayingScreen` reads `TrackLookupService` through its companion
  cubit (created in Phase 6 — for this phase, keep the existing
  in-screen lookup but pointed at the service via `getIt`).

**Acceptance.** Now Playing header still shows `fileType` after track
change. Analyzer + tests green.

**Notes (post-implementation).**
- Service de-dupes same-key lookups internally (`_lastFileKey`) so the
  `BlocConsumer.listenWhen` filter in `NowPlayingScreen` is now belt-
  and-braces — both layers prevent re-fetches.
- The screen still violates Rule 1 (binds to `PlayerCubit` +
  `PlayerControllerCubit` + reads `ActiveZoneService` and
  `TrackLookupService` via `StreamBuilder`); the comment in
  `NowPlayingScreen.build` now points to Phase 8 for the single-cubit
  fix.

### Phase 2 — `FavoritesService` (½ day) — ✅ done

**Goal.** Retire `FavoritesCubit`. Favorites tab + browse-item heart
toggle observe the service.

**Deliverables.**
- `lib/features/favorites/favorites_service.dart` + register in DI.
- `bloc/favorites_cubit.dart` deleted.
- New companion cubits:
  - `FavoritesTabCubit` paired with `FavoritesTab`.
  - `BrowseItemTileCubit` paired with `BrowseItemTile` (state is `bool
    isFavorite` + `toggle()`).
- `app.dart` registers `FavoritesTabCubit` at the right scope; tile
  cubits scope at the tile via `BlocProvider`.

**Acceptance.** Toggle a favorite from anywhere in the browse tree → it
appears in the Favorites tab. Analyzer + tests green.

**Notes (post-implementation).**
- Service de-dupes redundant emissions via a structural `_listEquals`
  comparing browse-item IDs.
- `FavoritesTabCubit` is scoped inside `FavoritesTab` (via the tab's
  `MultiBlocProvider`), not at the root — favorites state survives
  rebuilds within the tab but isn't kept alive globally; the service
  is the source of truth.
- `BrowseItemTileCubit` is per-tile (keyed `fav-${item.id}` so reused
  rows pick up the right state). The tile's body lives in a private
  `_Tile` widget that reads only the cubit — never the service.

### Phase 3 — Download stream services (½ day) — ✅ done

**Goal.** Retire `DownloadJobsCubit` and `DownloadedTracksCubit`.
Both are pure pipes off `DownloadsRepository` streams.

**Deliverables.**
- `lib/features/offline/download_jobs_service.dart`.
- `lib/features/offline/downloaded_tracks_service.dart`.
- Both registered in DI **before** `LocalPlaybackService` lands in
  Phase 7.
- Old cubit files deleted in this phase along with all widget
  consumers migrating to `StreamBuilder` reads of the service.

**Acceptance.** Existing tile chrome (progress indicators, popup-menu
entries) still works — wired temporarily via direct service reads /
`StreamBuilder` until Phase 4 introduces tile cubits.

**Notes (post-implementation).**
- Services pipe `repository.watchJobs()` and
  `repository.watchDownloadedTracks()` directly; subscriptions are
  cancelled in `dispose()`. Initial `state` is `const []` until the
  first emit.
- Widget migrations (no companion cubits yet — those land in Phase 4):
  `download_progress_indicator.dart`, `album_download_progress_indicator.dart`,
  `library_item_tile.dart`, `album_row_tile.dart`, `tracks_popup_menu.dart`,
  `server_manager_screen.dart` (storage + failed-downloads sections),
  `downloaded_artists_screen.dart`, `downloaded_albums_screen.dart`,
  `downloaded_album_detail_screen.dart`. All replaced
  `BlocBuilder<…Cubit, …>` with `StreamBuilder<…>` driven by
  `getIt<…Service>().stream` + `initialData: service.state`.
- `app.dart` drops both `BlocProvider`s; the `DownloadsRepository`
  import stays for `LocalPlayerCubit`'s constructor.

### Phase 4 — Download-aware tile / indicator companion cubits (1 day) — ✅ done

**Goal.** Replace the inline `StreamBuilder` / multi-`BlocBuilder` in
the download-aware widgets with single companion cubits per widget.

**Deliverables.** New companion cubits, one per widget:
- `DownloadProgressCubit` ↔ `DownloadProgressIndicator`.
- `AlbumDownloadProgressCubit` ↔ `AlbumDownloadProgressIndicator`.
- `LibraryItemTileCubit` ↔ `LibraryItemTile` (folds active-zone +
  downloads).
- `AlbumRowTileCubit` ↔ `AlbumRowTile`.
- `TracksPopupMenuCubit` ↔ `TracksPopupMenu`.
- `OfflineStorageCubit` ↔ `_StorageSection` of `ServerManagerScreen`.
- `FailedDownloadsCubit` ↔ `_FailedDownloadsSection`.

**Acceptance.** No widget in the library / offline tree reads
`DownloadJobsService` / `DownloadedTracksService` directly. Rule 1
satisfied for every tile.

**Notes (post-implementation).**
- All 7 companion cubits implemented and wired.
- Rule 2 (Widgets never touch services / repositories directly) enforced: action handlers (play, download, cancel, delete) moved into cubits.
- `LibraryItemTileCubit` and `AlbumRowTileCubit` now accept full `Track`/`Album` objects and manage their own dependencies via constructor injection.
- `ServerManagerScreen` refactored to remove `StreamBuilder` and direct `getIt<DownloadsRepository>` calls.

### Phase 5 — Downloaded screen companion cubits (½ day) — ✅ done

**Goal.** Same as Phase 4 but for the three downloaded-content screens.

**Deliverables.**
- `DownloadedArtistsCubit` ↔ `DownloadedArtistsScreen`.
- `DownloadedAlbumsCubit(artist)` ↔ `DownloadedAlbumsScreen`.
- `DownloadedAlbumDetailCubit(albumGroupId)` ↔
  `DownloadedAlbumDetailScreen`.

**Acceptance.** Offline Mode flow: download album → kill server →
relaunch → Continue Offline → drill into downloaded artists/albums →
play. Rule 1 satisfied for all three screens.

**Notes (post-implementation).**
- Three new screen-level companion cubits implemented.
- All filtering and sorting logic moved from widgets into cubits.
- Bulk actions (play/delete) for artists moved into `DownloadedArtistsCubit`.
- Rule 2 satisfied: no direct `DownloadedTracksService` or `DownloadsRepository` reads in the screens.

### Phase 6 — `McwsPlayerService` (1 day) — ✅ done

**Goal.** Retire `McwsPlayerBloc`. Its consumers are internal: only
`PlayerCubit` and `PlayerControllerCubit` reference it today.

**Deliverables.**
- `lib/features/player/mcws_player_service.dart` (owns the adaptive
  polling timer).
- DI registration with `lazy: false`-equivalent (eager `registerSingleton`).
- `PlayerCubit` and `PlayerControllerCubit` now read the service.
- `bloc/mcws_player_bloc.dart` deleted.
- Lifecycle hook in `_LifecycleScope` (app.dart) calls
  `getIt<McwsPlayerService>().pause()`/`resume()` instead of the cubit.

**Acceptance.** MCWS playback poll cadence unchanged (1 s playing, 5 s
idle). Pause/resume on app background still works. Analyzer + tests
green.

**Notes (post-implementation).**
- `McwsPlayerService` implemented as a standard GetIt singleton.
- `McwsPlayerBloc` file deleted and provider removed from `app.dart`.
- Core player cubits refactored to depend on the service via constructor injection.
- App lifecycle listener updated to use the service singleton for pause/resume.

### Phase 7 — `LocalPlaybackService` (1.5 days) — ✅ done

**Goal.** Retire `LocalPlayerCubit`. The most complex conversion —
queue persistence, downloads-set listener, AA handler swap all move
behind the service surface.

**Deliverables.**
- `lib/features/player/local_playback_service.dart`.
- Constructor subscribes to `LocalPlayerService` (audio_service
  handler), `ActiveZoneService`, `DownloadedTracksService`.
- `PlayerCubit`, `PlayerControllerCubit`, `QueueCubit` (still a cubit
  at this point — Phase 11 retires it) updated.
- `bloc/local_player_cubit.dart` deleted.

**Acceptance.** Pick Local zone → resume on relaunch with saved index/
position. Download a track in queue → URL swaps to file path mid-play.
AA handler swap on zone pick still works.

**Notes (post-implementation).**
- `LocalPlaybackService` fully implemented as an eager GetIt singleton.
- Migrated all complex state management (position, volume, sequence subscriptions) and persistence logic from the retired `LocalPlayerCubit`.
- Updated core player and queue cubits to resolve the service singleton via GetIt.
- Verified that all 48 tests pass and the codebase is clean of analyzer issues.

### Phase 8 — `PlayerService` + companion cubits (1 day) — ✅ done

**Goal.** Retire `PlayerCubit` facade. Add companion cubits for the two
widgets that consumed it.

**Deliverables.**
- `lib/features/player/player_service.dart` (forwards snapshots based
  on active zone).
- New companion cubits:
  - `NowPlayingCubit` ↔ `NowPlayingScreen` — aggregates
    `PlayerService` snapshot + `ActiveZoneService.state` +
    `TrackLookupService` enrichment into one `NowPlayingState`.
  - `MiniPlayerCubit` ↔ `MiniPlayerPanel`.
- `LibraryCubit` ↔ `LibraryScreen` — `isOffline` from `ActiveZoneService`
  + active tab.
- `bloc/player_cubit.dart` deleted.

**Acceptance.** Now Playing tab renders end-to-end with one cubit per
widget. Mini-player updates as track changes. Library tabs collapse
to Downloads-only when Offline. Rule 1 satisfied across the player UI.

**Notes (post-implementation).**
- `PlayerService` is the GetIt-registered facade that forwards the
  active zone's player snapshot (MCWS or Local) on a single stream.
- `NowPlayingCubit` aggregates `PlayerService` + `ActiveZoneService` +
  `TrackLookupService` enrichment into one immutable `NowPlayingState`.
- `MiniPlayerCubit` reads `PlayerService` directly.
- `LibraryCubit` ↔ `LibraryScreen` reads `ActiveZoneService` for
  `isOffline` and owns the active tab index. `LibraryState` is a
  plain immutable class (not Freezed) — only two fields.
- `bloc/player_cubit.dart` removed; `player_state.dart` kept as the
  shared snapshot type used by the player services and companion
  cubits.
- `flutter analyze` clean. All 48 tests pass.

### Phase 9 — `PlayerCommandService` (½ day) — ✅ done

**Goal.** Retire `PlayerControllerCubit`. Becomes a stateless command
sink in the service container.

**Deliverables.**
- `lib/features/player/player_command_service.dart`.
- All companion cubits that today resolve `PlayerControllerCubit` via
  `context.read` are updated to resolve `PlayerCommandService` via
  `getIt`.
- The `RepositoryProvider<PlayerControllerCubit>` in `app.dart` is
  removed.
- `bloc/player_controller_cubit.dart` deleted.

**Acceptance.** Every transport button + every Play / Play next / Add
popup still fires the right path. Analyzer + tests green.

**Notes (post-implementation).**
- `PlayerCommandService` is a stateless GetIt singleton implementing
  `PlayerController`. Routes commands to MCWS or Local by active zone.
- Companion cubits (`AlbumRowTileCubit`, `LibraryItemTileCubit`,
  `TracksPopupMenuCubit`, `DownloadedArtistsCubit`) now take
  `PlayerCommandService` via constructor and own the action methods
  outright — widgets no longer pass a controller in.
- Widgets without a companion cubit yet (`QueueScreen`,
  `NowPlayingScreen` transport buttons, `MiniPlayerPanel`,
  `LibraryActionSheet`) resolve `PlayerCommandService` via
  `getIt` directly. These tighten further when their companion
  cubits land (Phase 11 for queue; others stay as transport hosts).
- `RepositoryProvider<PlayerControllerCubit>` removed from `app.dart`.
- `bloc/player_controller_cubit.dart` deleted; the
  `PlayerController` interface in `bloc/player_controller.dart`
  remains as the shared command surface for the two engines.
- `flutter analyze` clean. All 48 tests pass.

### Phase 10 — `ZonesService` (½ day) — ✅ done

**Goal.** Retire `ZonesCubit`. `ZoneListCubit` already exists and is
the only screen-level cubit; it now reads the service.

**Deliverables.**
- `lib/features/zones/zones_service.dart` (owns the 30 s timer).
- `ZoneListCubit` updated to take `ZonesService` + `ActiveZoneService`.
- `bloc/zones_cubit.dart` deleted.
- Lifecycle hook updated to call `getIt<ZonesService>().pause()`/
  `.resume()`.

**Acceptance.** Zone list refreshes on a 30 s tick. App background
pauses; foreground resumes. Auto-zone (Phase 10 of the original plan)
still surfaces.

**Notes (post-implementation).**
- `ZonesService` is an eager GetIt singleton. Owns the 30 s polling
  timer, subscribes to `SessionService` (start/stop on auth flips)
  and to `ActiveZoneService` (pause when the user picks Offline).
  Emits `ZonesState` (the existing Freezed union, reused as-is).
- `ZoneListCubit` now takes `ZonesService` directly via constructor.
- `BlocProvider<ZonesCubit>` removed from `app.dart`. Lifecycle hook
  calls `getIt<ZonesService>().pause()` / `.resume()` instead of
  reading from the widget tree.
- `bloc/zones_cubit.dart` deleted; the `ZonesState` Freezed union
  stays put (shared by service and `ZoneListCubit`).
- `flutter analyze` clean. All 48 tests pass.

### Phase 11 — `QueueService` + companion cubit (1 day) — ✅ done

**Goal.** Retire `QueueCubit`. `QueueScreen` gets a paired companion.

**Deliverables.**
- `lib/features/queue/queue_service.dart` — drives the playing-now
  change-counter watch via `PlayerService.stream` and the local
  sequence via `LocalPlayerService.sequenceStateStream`.
- `QueueScreenCubit` ↔ `QueueScreen` — single `QueueScreenState`
  aggregating queue tracks + current index.
- `bloc/queue_cubit.dart` deleted.

**Acceptance.** Queue updates on MCWS change-counter bumps and on
local sequence changes. Reorder / remove / clear still work.

**Notes (post-implementation).**
- `QueueService` is an eager GetIt singleton. Owns the queue snapshot
  and the three subscriptions (active zone, player snapshots, local
  sequence). Exposes `state`/`stream` plus `refresh`/`removeItem`/
  `moveItem`/`clearQueue`. Reuses the existing `QueueState` Freezed
  union as its surface (no separate `QueueScreenState` was needed
  since the screen's state shape is the same).
- `QueueScreenCubit` ↔ `QueueScreen` — mirrors the service stream
  and forwards mutation + `playByIndex` calls. Resolves the service
  and `PlayerCommandService` via `getIt` at construction.
- `BlocProvider<QueueCubit>` removed from `app.dart`.
- `bloc/queue_cubit.dart` deleted.
- `flutter analyze` clean. All 48 tests pass.

### Phase 12 — Cleanup & verification (½ day)

**Goal.** Sweep leftovers, format, document.

**Deliverables.**
- `dart format .`, `dart fix --apply`.
- Update `PLAN.md` §13 cross-references that point at the retired
  cubits.
- Verify with `flutter analyze` + `flutter test` + a multi-platform
  smoke test (macOS, iOS, Android, optionally Windows/Linux).
- Tag the resulting commit (e.g. `v2.0.0-services`).

**Acceptance.** No widget reads a service directly. No cubit/bloc
extends `Cubit<T>` while exposing fields/methods beyond `state` +
input methods. Every cubit pairs to exactly one widget by name.

### Timeline summary

| Phase | Title                                              | Effort   |
|-------|----------------------------------------------------|----------|
| 1     | TrackLookupService ✅                              | ½ day    |
| 2     | FavoritesService ✅                                | ½ day    |
| 3     | Download stream services ✅                        | ½ day    |
| 4     | Download-aware tile / indicator companion cubits ✅ | 1 day    |
| 5     | Downloaded screen companion cubits ✅              | ½ day    |
| 6     | McwsPlayerService ✅                               | 1 day    |
| 7     | LocalPlaybackService ✅                            | 1.5 days |
| 8     | PlayerService + companion cubits ✅                | 1 day    |
| 9     | PlayerCommandService ✅                            | ½ day    |
| 10    | ZonesService ✅                                    | ½ day    |
| 11    | QueueService + companion cubit ✅                  | 1 day    |
| 12    | Cleanup & verification                             | ½ day    |
| **Total** |                                                | **~8.5 days** |

---

## 5. Widget Companion Cubits

One cubit per widget. Each emits a single `<Name>State` and forwards
commands to the underlying service(s).

| Widget | Companion Cubit | Sources |
|---|---|---|
| `RootScreen` | `RootCubit` (exists) | `SessionService` |
| `ServerSetupScreen` | `ServerSetupCubit` (exists) | `SessionService` |
| `ServerManagerScreen` | `ServerManagerCubit` (exists) | `SessionService` |
| `ArtworkWidget` | `ArtworkCubit` (exists) | `SessionService`, `ConnectionRepository` |
| `ZoneListScreen` | `ZoneListCubit` (exists) | `ZonesService`, `ActiveZoneService` |
| `NowPlayingScreen` | **new `NowPlayingCubit`** | `PlayerService`, `ActiveZoneService`, `TrackLookupService` |
| `MiniPlayerPanel` | **new `MiniPlayerCubit`** | `PlayerService` |
| `QueueScreen` | **new `QueueCubit`** (paired) | `QueueService`, `PlayerService` |
| `LibraryScreen` | **new `LibraryCubit`** | `ActiveZoneService` (offline tab swap) |
| `FavoritesTab` | **new `FavoritesTabCubit`** | `FavoritesService`, `BrowseNavigationCubit` |
| `BrowseItemTile` | **new `BrowseItemTileCubit`** (or fold into parent — TBD) | `FavoritesService` |
| `LibraryItemTile` | **new `LibraryItemTileCubit`** | `ActiveZoneService`, `DownloadedTracksService`, `DownloadJobsService` |
| `AlbumRowTile` | **new `AlbumRowTileCubit`** | `ActiveZoneService`, `DownloadedTracksService`, `DownloadJobsService` |
| `TracksPopupMenu` | **new `TracksPopupMenuCubit`** | `ActiveZoneService`, `DownloadedTracksService`, `DownloadJobsService` |
| `DownloadProgressIndicator` | **new `DownloadProgressCubit`** | `DownloadedTracksService`, `DownloadJobsService` |
| `AlbumDownloadProgressIndicator` | **new `AlbumDownloadProgressCubit`** | `DownloadJobsService` |
| `ServerManagerScreen` storage section | **new `OfflineStorageCubit`** | `DownloadedTracksService` |
| `ServerManagerScreen` failed-downloads section | **new `FailedDownloadsCubit`** | `DownloadJobsService` |
| `DownloadedArtistsScreen` | **new `DownloadedArtistsCubit`** | `DownloadedTracksService` |
| `DownloadedAlbumsScreen` | **new `DownloadedAlbumsCubit`** (param: artist) | `DownloadedTracksService` |
| `DownloadedAlbumDetailScreen` | **new `DownloadedAlbumDetailCubit`** (param: albumGroupId) | `DownloadedTracksService` |

Tile-level cubits (LibraryItemTile, AlbumRowTile, DownloadProgressIndicator,
etc.) are created per-instance via `BlocProvider` at the tile itself, or
via `ListView.builder` wrapping each tile in its own `BlocProvider`.

---

## 6. State Class Conventions

- Always Freezed (`@freezed` for unions, `@freezed` data classes for
  simple aggregates) so equality + `copyWith` are free.
- One file per state class: `lib/features/<feature>/bloc/<name>_state.dart`.
- State name = cubit name minus `Cubit`/`Bloc` suffix: `NowPlayingState`,
  `MiniPlayerState`, etc.
- For tiles / progress indicators, keep the state minimal: just the
  fields the widget reads.

---

## 7. File Layout

```
lib/features/<feature>/
  <feature>_service.dart           ← new services live here, not in bloc/
  bloc/
    <widget>_cubit.dart            ← widget-paired companion cubits
    <widget>_state.dart            ← + .freezed.dart
  data/...                          ← unchanged
  widgets/...                       ← unchanged file paths
```

Existing services (`LocalPlayerService` — audio_service handler,
`SessionService`, `ActiveZoneService`, `AndroidAutoSessionService`,
`JrrAudioHandler`) stay where they are.

---

## 8. Testing

- Each new service gets a `<name>_service_test.dart` that constructs the
  service with mocktail-ed repositories and asserts state transitions.
- Each new companion cubit gets a `<name>_cubit_test.dart` using
  `bloc_test` with mocked services.
- Widget tests for already-tested screens (currently none — port the
  Riverpod-era widget tests when this pass lands).

---

## 9. Risk Notes

- **Dependency cycles.** `PlayerService` reads from
  `LocalPlaybackService`, but `LocalPlaybackService` listens to
  `DownloadedTracksService`. Make sure `DownloadedTracksService` is
  registered before `LocalPlaybackService`, which is before
  `PlayerService`. Codify in `injection.dart` via the migration order
  (§4).
- **Eager construction.** All services must be registered with
  `getIt.registerSingleton<…>(…)` — `registerLazySingleton` would defer
  the side-effects (polling, subscriptions) and reproduce the "loader
  forever" bug we already fixed for cubits.
- **AudioService handler swap.** `LocalPlaybackService` switches the
  active sub-handler via `JrrAudioHandler.switchTo`. Keep this code
  path intact; today it lives in `LocalPlayerCubit._onZoneChanged`.
- **`PlayerCommandService` exception.** It's a command sink with no
  state. Document the exception inline in the file's docstring so the
  reader doesn't expect a `state` getter.
- **State equality.** Every service `_emit` guards against
  `state == next` — easy to forget on `PlayerSnapshot` because it's a
  Freezed union with deep equality; verify each branch.
- **Widget tests.** `bloc_test`'s `MockCubit` works with companion
  cubits; for code that previously read a cubit directly from getIt,
  the test setup needs to provide a `MockSomeService` via
  `getIt.registerSingleton<SomeService>(mock)` before the widget pumps.

---

## 10. Acceptance per Step

Each of the nine migration steps in §4 must:

1. Add the service file and register it in `injection.dart`.
2. Update all bloc consumers to depend on the service.
3. Build/refactor companion cubits for affected widgets, satisfying
   Architecture Rules 1–4.
4. Delete the original cubit/bloc file once nothing references it.
5. `flutter analyze` clean, `flutter test` green.
6. Manual smoke-test on macOS or iOS:
   - Now Playing tab loads on cold start.
   - Library Search debounces and renders results.
   - Download / Cancel / Delete entries fire on the right paths.
   - Offline Mode short-circuits library tabs.
   - Zone switch persists across restart.

---

## 11. Out of Scope (Follow-ups)

- AutoTabsRouter migration (PLAN §13 Phase 9 deviation — separate pass).
- `JrrAudioHandler` ↔ `LocalPlaybackService` stream re-subscription so
  the phone UI mirrors AA-side playback (PLAN §13 Phase 10 deviation).
- Replacing `LocalAudioQualityCubit` and `LibraryChromeCubit` with
  per-screen state — they don't have a service shape and aren't worth
  the ceremony.
