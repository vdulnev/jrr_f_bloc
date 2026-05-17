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

/// Phase 8 root: same five-tab shell, now with the full ServerManagerScreen
/// instead of the stub info view. Phase 9 swaps in auto_route + adaptive
/// (narrow / wide) layout.
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

class _AuthenticatedShell extends StatefulWidget {
  const _AuthenticatedShell();

  @override
  State<_AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<_AuthenticatedShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                NowPlayingScreen(),
                QueueScreen(),
                LibraryScreen(),
                ZoneListScreen(),
                ServerManagerScreen(),
              ],
            ),
          ),
          if (_tab != 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: MiniPlayerPanel(onItemTap: () => setState(() => _tab = 0)),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
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
    );
  }
}
