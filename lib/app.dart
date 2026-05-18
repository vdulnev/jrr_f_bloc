import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/orientation/orientation_lock.dart';
import 'core/router/app_router.dart';
import 'core/router/navigation_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/connection/bloc/session_cubit.dart';
import 'features/connection/data/repositories/connection_repository.dart';
import 'features/favorites/bloc/favorites_cubit.dart';
import 'features/favorites/data/repositories/favorites_repository.dart';
import 'features/library/bloc/library_chrome_cubit.dart';
import 'features/library/bloc/search_by_file_key_cubit.dart';
import 'features/library/data/repositories/library_repository.dart';
import 'features/offline/bloc/download_jobs_cubit.dart';
import 'features/offline/bloc/downloaded_tracks_cubit.dart';
import 'features/offline/data/repositories/downloads_repository.dart';
import 'features/player/bloc/local_audio_quality_cubit.dart';
import 'features/player/bloc/local_player_cubit.dart';
import 'features/player/bloc/mcws_player_bloc.dart';
import 'features/player/bloc/player_controller_cubit.dart';
import 'features/player/bloc/player_cubit.dart';
import 'features/player/data/repositories/player_repository.dart';
import 'features/player/services/local_player_service.dart';
import 'features/queue/bloc/queue_cubit.dart';
import 'features/queue/data/repositories/local_queue_repository.dart';
import 'features/queue/data/repositories/queue_repository.dart';
import 'features/zones/bloc/active_zone_cubit.dart';
import 'features/zones/bloc/zones_cubit.dart';
import 'features/zones/data/repositories/zone_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
        BlocProvider<SessionCubit>(
          create: (_) => SessionCubit(
            repository: getIt<ConnectionRepository>(),
            prefs: getIt(),
            talker: getIt(),
          ),
        ),
        BlocProvider<ActiveZoneCubit>(
          create: (_) => ActiveZoneCubit(prefs: getIt(), talker: getIt()),
        ),
        // ZonesCubit polls the server and drives ActiveZoneCubit.
        // Lazy creation would leave the active zone null until the user
        // visits the Zones tab — and the Now Playing screen waits on
        // that to leave its loader.
        BlocProvider<ZonesCubit>(
          lazy: false,
          create: (ctx) => ZonesCubit(
            repository: getIt<ZoneRepository>(),
            session: ctx.read<SessionCubit>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
            talker: getIt(),
          ),
        ),
        BlocProvider<LocalAudioQualityCubit>(
          create: (_) => LocalAudioQualityCubit(prefs: getIt()),
        ),
        // McwsPlayerBloc owns the Playback/Info polling timer; must run
        // independently of whether a UI consumer exists.
        BlocProvider<McwsPlayerBloc>(
          lazy: false,
          create: (ctx) => McwsPlayerBloc(
            repository: getIt<PlayerRepository>(),
            library: getIt<LibraryRepository>(),
            session: ctx.read<SessionCubit>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
            talker: getIt(),
          ),
        ),
        // LocalPlayerCubit owns just_audio stream subscriptions and the
        // per-zone queue restore on launch.
        BlocProvider<LocalPlayerCubit>(
          lazy: false,
          create: (ctx) => LocalPlayerCubit(
            service: getIt<LocalPlayerService>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
            queueRepository: getIt<LocalQueueRepository>(),
            downloadsRepository: getIt<DownloadsRepository>(),
            prefs: getIt(),
            talker: getIt(),
          ),
        ),
        // PlayerCubit forwards snapshots from MCWS / Local based on zone.
        BlocProvider<PlayerCubit>(
          lazy: false,
          create: (ctx) => PlayerCubit(
            mcws: ctx.read<McwsPlayerBloc>(),
            local: ctx.read<LocalPlayerCubit>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
          ),
        ),
        // QueueCubit watches the playing-now change counter; eager so
        // the queue is current the moment the user opens the tab.
        BlocProvider<QueueCubit>(
          lazy: false,
          create: (ctx) => QueueCubit(
            repository: getIt<QueueRepository>(),
            service: getIt<LocalPlayerService>(),
            localPlayer: ctx.read<LocalPlayerCubit>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
            player: ctx.read<PlayerCubit>(),
            talker: getIt(),
          ),
        ),
        BlocProvider<LibraryChromeCubit>(create: (_) => LibraryChromeCubit()),
        BlocProvider<SearchByFileKeyCubit>(
          create: (_) =>
              SearchByFileKeyCubit(repository: getIt<LibraryRepository>()),
        ),
        // Favorites + downloads cubits expose stream-backed state used by
        // tile chrome across the library — eager so tiles never render
        // with stale "not downloaded" badges before the first emission.
        BlocProvider<FavoritesCubit>(
          lazy: false,
          create: (_) =>
              FavoritesCubit(repository: getIt<FavoritesRepository>()),
        ),
        BlocProvider<DownloadJobsCubit>(
          lazy: false,
          create: (_) =>
              DownloadJobsCubit(repository: getIt<DownloadsRepository>()),
        ),
        BlocProvider<DownloadedTracksCubit>(
          lazy: false,
          create: (_) =>
              DownloadedTracksCubit(repository: getIt<DownloadsRepository>()),
        ),
      ],
      child: RepositoryProvider<PlayerControllerCubit>(
        create: (ctx) => PlayerControllerCubit(
          mcws: ctx.read<McwsPlayerBloc>(),
          local: ctx.read<LocalPlayerCubit>(),
          activeZone: ctx.read<ActiveZoneCubit>(),
        ),
        child: _LifecycleScope(child: _MaterialApp(router: _router)),
      ),
    );
  }
}

class _MaterialApp extends StatelessWidget {
  final AppRouter router;
  const _MaterialApp({required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JRiver Remote',
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router.config(),
      builder: (context, child) =>
          OrientationLock(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Pauses/resumes the polling blocs (zones, MCWS player) on app lifecycle
/// transitions per spec §5.3.
class _LifecycleScope extends StatefulWidget {
  final Widget child;
  const _LifecycleScope({required this.child});

  @override
  State<_LifecycleScope> createState() => _LifecycleScopeState();
}

class _LifecycleScopeState extends State<_LifecycleScope> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onPause: () {
        context.read<ZonesCubit>().pause();
        context.read<McwsPlayerBloc>().pause();
      },
      onResume: () {
        context.read<ZonesCubit>().resume();
        context.read<McwsPlayerBloc>().resume();
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
