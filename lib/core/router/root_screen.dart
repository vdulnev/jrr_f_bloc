import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';
import '../../features/connection/session_service.dart';
import '../../features/connection/bloc/root_cubit.dart';
import '../../features/connection/bloc/session_state.dart';
import '../../features/connection/widgets/server_setup_screen.dart';
import '../../shared/widgets/loading_view.dart';
import '../layout/adaptive_layout.dart';
import '../layout/two_panel_shell.dart';
import 'narrow_shell.dart';

/// Auth swap (login vs. shell) is driven by [RootCubit] — the
/// unauthenticated case short-circuits the whole shell. Tab state lives
/// in NavigationCubit so it survives any rebuild and is observable from
/// other blocs. The shell itself adapts to screen width: a bottom-bar
/// IndexedStack on phones, a sidebar + content split on tablet / desktop
/// (≥600dp).
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // RootScreen's companion — observes SessionService and emits
    // SessionState so the root router never touches the service
    // directly.
    return BlocProvider<RootCubit>(
      lazy: false,
      create: (_) => RootCubit(session: getIt<SessionService>()),
      child: BlocBuilder<RootCubit, SessionState>(
        builder: (context, state) => switch (state) {
          Restoring() => const Scaffold(body: LoadingView()),
          Unauthenticated() => const ServerSetupScreen(),
          Authenticated() => const _AuthenticatedShell(),
        },
      ),
    );
  }
}

class _AuthenticatedShell extends StatelessWidget {
  const _AuthenticatedShell();

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutBuilder(
      narrowBuilder: (_) => const NarrowShell(),
      wideBuilder: (_) => const TwoPanelShell(),
    );
  }
}
