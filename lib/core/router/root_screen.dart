import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/connection/bloc/session_cubit.dart';
import '../../features/connection/bloc/session_state.dart';
import '../../features/connection/data/models/server_info.dart';
import '../../features/connection/widgets/server_setup_screen.dart';
import '../../features/library/widgets/library_screen.dart';
import '../../features/player/widgets/mini_player_panel.dart';
import '../../features/player/widgets/now_playing_screen.dart';
import '../../features/queue/widgets/queue_screen.dart';
import '../../features/zones/widgets/zone_list_screen.dart';
import '../../shared/widgets/loading_view.dart';
import '../theme/app_theme.dart';

/// Phase 5 root: swaps between login and a placeholder shell that surfaces
/// the screens shipped so far. The proper auto_route tree lands in Phase 9.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) => switch (state) {
        Restoring() => const Scaffold(body: LoadingView()),
        Unauthenticated() => const ServerSetupScreen(),
        Authenticated(:final serverInfo) => _AuthenticatedShell(
          serverInfo: serverInfo,
        ),
      },
    );
  }
}

class _AuthenticatedShell extends StatefulWidget {
  final ServerInfo serverInfo;
  const _AuthenticatedShell({required this.serverInfo});

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
              children: [
                const NowPlayingScreen(),
                const QueueScreen(),
                const LibraryScreen(),
                const ZoneListScreen(),
                _ServerInfoView(serverInfo: widget.serverInfo),
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

class _ServerInfoView extends StatelessWidget {
  final ServerInfo serverInfo;
  const _ServerInfoView({required this.serverInfo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONNECTED', style: AppTextStyles.sectionLabel),
                      SizedBox(height: 6),
                      Text('Server', style: AppTextStyles.screenTitle),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Logout',
                  onPressed: () => context.read<SessionCubit>().logout(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Row(label: 'Name', value: serverInfo.name),
            _Row(label: 'Version', value: serverInfo.version),
            _Row(label: 'Platform', value: serverInfo.platform),
            _Row(label: 'Address', value: serverInfo.address),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.itemSubtitle),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.monoLabel.copyWith(
                color: AppColors.text,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
