import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/orientation/orientation_lock.dart';
import 'core/router/app_router.dart';
import 'core/router/navigation_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/connection/bloc/artwork_cubit.dart';
import 'features/connection/bloc/root_cubit.dart';
import 'features/connection/data/repositories/connection_repository.dart';
import 'features/connection/session_service.dart';
import 'features/library/bloc/library_chrome_cubit.dart';
import 'features/player/bloc/local_audio_quality_cubit.dart';
import 'features/player/local_playback_service.dart';
import 'features/player/mcws_player_service.dart';
import 'features/player/player_service.dart';
import 'features/player/services/local_player_service.dart';
import 'features/queue/bloc/queue_cubit.dart';
import 'features/queue/data/repositories/queue_repository.dart';
import 'features/zones/active_zone_service.dart';
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
        // RootScreen's companion — observes SessionService and emits
        // SessionState so the root router never touches the service
        // directly.
        BlocProvider<RootCubit>(
          lazy: false,
          create: (_) => RootCubit(session: getIt<SessionService>()),
        ),
        // Connection snapshot used by ArtworkWidget to compose image URLs.
        BlocProvider<ArtworkCubit>(
          lazy: false,
          create: (_) => ArtworkCubit(
            session: getIt<SessionService>(),
            repository: getIt<ConnectionRepository>(),
          ),
        ),
        // ZonesCubit polls the server and drives ActiveZoneService.
        // Lazy creation would leave the active zone null until the user
        // visits the Zones tab — and the Now Playing screen waits on
        // that to leave its loader.
        BlocProvider<ZonesCubit>(
          lazy: false,
          create: (_) => ZonesCubit(
            repository: getIt<ZoneRepository>(),
            session: getIt<SessionService>(),
            activeZone: getIt<ActiveZoneService>(),
            talker: getIt(),
          ),
        ),
        BlocProvider<LocalAudioQualityCubit>(
          create: (_) => LocalAudioQualityCubit(prefs: getIt()),
        ),
        // QueueCubit watches the playing-now change counter; eager so
        // the queue is current the moment the user opens the tab.
        BlocProvider<QueueCubit>(
          lazy: false,
          create: (ctx) => QueueCubit(
            repository: getIt<QueueRepository>(),
            service: getIt<LocalPlayerService>(),
            localPlayer: getIt<LocalPlaybackService>(),
            activeZone: getIt<ActiveZoneService>(),
            player: getIt<PlayerService>(),
            talker: getIt(),
          ),
        ),
        BlocProvider<LibraryChromeCubit>(create: (_) => LibraryChromeCubit()),
      ],
      child: _LifecycleScope(child: _MaterialApp(router: _router)),
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
        getIt<McwsPlayerService>().pause();
      },
      onResume: () {
        context.read<ZonesCubit>().resume();
        getIt<McwsPlayerService>().resume();
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
