import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/connection/bloc/session_cubit.dart';
import '../../features/connection/bloc/session_state.dart';
import '../../features/connection/widgets/server_manager_screen.dart';
import '../../features/connection/widgets/server_setup_screen.dart';
import '../../features/library/widgets/library_screen.dart';
import '../../features/player/widgets/mini_player_panel.dart';
import '../../features/player/widgets/now_playing_screen.dart';
import '../../features/queue/widgets/queue_screen.dart';
import '../../features/zones/widgets/zone_list_screen.dart';
import '../../shared/widgets/loading_view.dart';
import 'navigation_cubit.dart';

/// Phase 9 root. Auth swap (login vs. shell) stays driven by SessionCubit
/// because the unauthenticated case isn't really a sub-route — it short-
/// circuits the entire shell. Tab state lives in NavigationCubit so it
/// survives any rebuild of the shell's widget tree and is observable from
/// other blocs.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) => switch (state) {
        Restoring() => const Scaffold(body: LoadingView()),
        Unauthenticated() => const ServerSetupScreen(),
        Authenticated() => const _AuthenticatedShell(),
      },
    );
  }
}

class _AuthenticatedShell extends StatelessWidget {
  const _AuthenticatedShell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppTab>(
      builder: (context, tab) => Scaffold(
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: tab.index,
                children: const [
                  NowPlayingScreen(),
                  QueueScreen(),
                  LibraryScreen(),
                  ZoneListScreen(),
                  ServerManagerScreen(),
                ],
              ),
            ),
            if (tab != AppTab.nowPlaying)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: MiniPlayerPanel(
                  onItemTap: () => context
                      .read<NavigationCubit>()
                      .select(AppTab.nowPlaying),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected: (i) =>
              context.read<NavigationCubit>().select(AppTab.values[i]),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.album_outlined),
              label: 'Playing',
            ),
            NavigationDestination(
              icon: Icon(Icons.queue_music_outlined),
              label: 'Queue',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.speaker_group_outlined),
              label: 'Zones',
            ),
            NavigationDestination(
              icon: Icon(Icons.dns_outlined),
              label: 'Server',
            ),
          ],
        ),
      ),
    );
  }
}
