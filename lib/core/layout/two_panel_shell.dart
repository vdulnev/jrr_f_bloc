import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/connection/widgets/server_manager_screen.dart';
import '../../features/library/bloc/library_chrome_cubit.dart';
import '../../features/library/widgets/library_screen.dart';
import '../../features/player/widgets/mini_player_panel.dart';
import '../../features/player/widgets/now_playing_screen.dart';
import '../../features/queue/widgets/queue_screen.dart';
import '../../features/zones/widgets/zone_list_screen.dart';
import '../router/navigation_cubit.dart';
import '../theme/app_theme.dart';
import 'sidebar.dart';

/// Wide-screen shell: a fixed-width sidebar on the left, the active
/// tab's content on the right, mini-player docked below the content
/// when the user is on any tab other than Now Playing.
class TwoPanelShell extends StatelessWidget {
  const TwoPanelShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg1,
      child: BlocBuilder<NavigationCubit, AppTab>(
        builder: (context, active) => Row(
          children: [
            const Sidebar(),
            Expanded(child: _MainPanel(activeTab: active)),
          ],
        ),
      ),
    );
  }
}

class _MainPanel extends StatelessWidget {
  final AppTab activeTab;
  const _MainPanel({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final showMiniPlayer = activeTab != AppTab.nowPlaying;
    return Column(
      children: [
        Expanded(child: _ContentArea(activeTab: activeTab)),
        if (showMiniPlayer)
          BlocBuilder<LibraryChromeCubit, bool>(
            builder: (context, chromeVisible) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: chromeVisible
                    ? Container(
                        decoration: const BoxDecoration(
                          color: AppColors.bg1,
                          border: Border(
                            top: BorderSide(color: AppColors.line),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: MiniPlayerPanel(
                          onItemTap: () => context
                              .read<NavigationCubit>()
                              .select(AppTab.nowPlaying),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              );
            },
          ),
      ],
    );
  }
}

class _ContentArea extends StatelessWidget {
  final AppTab activeTab;
  const _ContentArea({required this.activeTab});

  @override
  Widget build(BuildContext context) => switch (activeTab) {
    AppTab.nowPlaying => const NowPlayingScreen(),
    AppTab.queue => const QueueScreen(),
    AppTab.library => const LibraryScreen(),
    AppTab.zones => const ZoneListScreen(),
    AppTab.settings => const ServerManagerScreen(),
  };
}
