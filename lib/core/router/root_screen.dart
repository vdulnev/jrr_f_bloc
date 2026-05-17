import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/connection/bloc/session_cubit.dart';
import '../../features/connection/bloc/session_state.dart';
import '../../features/connection/data/models/server_info.dart';
import '../../features/connection/widgets/server_setup_screen.dart';
import '../../shared/widgets/loading_view.dart';
import '../theme/app_theme.dart';

/// Phase 3 root: swap between login and a placeholder authenticated shell
/// based on [SessionState]. The full auto_route tree with library / queue /
/// player tabs comes back in Phase 9 once those features exist.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) => switch (state) {
        Restoring() => const Scaffold(body: LoadingView()),
        Unauthenticated() => const ServerSetupScreen(),
        Authenticated(:final serverInfo) => _PlaceholderShell(
          serverInfo: serverInfo,
        ),
      },
    );
  }
}

/// Stand-in for the authenticated shell. Phases 4–8 swap individual sections
/// in (zones, player, queue, library, etc.). This screen exists so the
/// connection slice is demoable end-to-end.
class _PlaceholderShell extends StatelessWidget {
  final ServerInfo serverInfo;

  const _PlaceholderShell({required this.serverInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JRiver Remote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => context.read<SessionCubit>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CONNECTED', style: AppTextStyles.sectionLabel),
            const SizedBox(height: 8),
            Text(serverInfo.name, style: AppTextStyles.screenTitle),
            const SizedBox(height: 16),
            _Row(label: 'Version', value: serverInfo.version),
            _Row(label: 'Platform', value: serverInfo.platform),
            _Row(label: 'Address', value: serverInfo.address),
            const SizedBox(height: 24),
            const Text(
              'Subsequent phases bring zones, player, queue, library, '
              'favorites, downloads, and routing.',
              style: AppTextStyles.itemSubtitle,
            ),
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
