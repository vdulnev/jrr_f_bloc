import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/orientation/orientation_lock.dart';
import 'core/router/root_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/connection/bloc/session_cubit.dart';
import 'features/connection/data/repositories/connection_repository.dart';
import 'features/library/data/repositories/library_repository.dart';
import 'features/player/bloc/local_audio_quality_cubit.dart';
import 'features/player/bloc/local_player_cubit.dart';
import 'features/player/bloc/mcws_player_bloc.dart';
import 'features/player/bloc/player_controller_cubit.dart';
import 'features/player/bloc/player_cubit.dart';
import 'features/player/data/repositories/player_repository.dart';
import 'features/player/services/local_player_service.dart';
import 'features/zones/bloc/active_zone_cubit.dart';
import 'features/zones/bloc/zones_cubit.dart';
import 'features/zones/data/repositories/zone_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(
          create: (_) => SessionCubit(
            repository: getIt<ConnectionRepository>(),
            prefs: getIt(),
            talker: getIt(),
          ),
        ),
        BlocProvider<ActiveZoneCubit>(
          create: (_) =>
              ActiveZoneCubit(prefs: getIt(), talker: getIt()),
        ),
        BlocProvider<ZonesCubit>(
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
        BlocProvider<McwsPlayerBloc>(
          create: (ctx) => McwsPlayerBloc(
            repository: getIt<PlayerRepository>(),
            library: getIt<LibraryRepository>(),
            session: ctx.read<SessionCubit>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
            talker: getIt(),
          ),
        ),
        BlocProvider<LocalPlayerCubit>(
          create: (ctx) => LocalPlayerCubit(
            service: getIt<LocalPlayerService>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
            talker: getIt(),
          ),
        ),
        BlocProvider<PlayerCubit>(
          create: (ctx) => PlayerCubit(
            mcws: ctx.read<McwsPlayerBloc>(),
            local: ctx.read<LocalPlayerCubit>(),
            activeZone: ctx.read<ActiveZoneCubit>(),
          ),
        ),
      ],
      child: RepositoryProvider<PlayerControllerCubit>(
        create: (ctx) => PlayerControllerCubit(
          mcws: ctx.read<McwsPlayerBloc>(),
          local: ctx.read<LocalPlayerCubit>(),
          activeZone: ctx.read<ActiveZoneCubit>(),
        ),
        child: const _LifecycleScope(child: _MaterialApp()),
      ),
    );
  }
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JRiver Remote',
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      home: const RootScreen(),
      builder: (context, child) =>
          OrientationLock(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Pauses/resumes the polling blocs (zones, MCWS player) on app lifecycle
/// transitions per spec §5.3. The blocs themselves cancel timers in their
/// `pause()` method; this scope just delivers the signal.
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
