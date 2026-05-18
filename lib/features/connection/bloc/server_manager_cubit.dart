import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/server_info.dart';
import '../session_service.dart';
import 'server_manager_state.dart';
import 'session_state.dart';

/// Cubit for the Server Manager's auth section. Surfaces the currently
/// authenticated [ServerInfo] (or null when unauthenticated) and exposes
/// `logout()` so the screen never reaches into [SessionService] directly.
class ServerManagerCubit extends Cubit<ServerManagerState> {
  final SessionService _session;
  StreamSubscription<SessionState>? _sub;

  ServerManagerCubit({required SessionService session})
    : _session = session,
      super(ServerManagerState(serverInfo: _serverInfoFor(session.state))) {
    _sub = _session.stream.listen(
      (s) => emit(ServerManagerState(serverInfo: _serverInfoFor(s))),
    );
  }

  static ServerInfo? _serverInfoFor(SessionState s) => switch (s) {
    Authenticated(:final serverInfo) => serverInfo,
    _ => null,
  };

  Future<void> logout() => _session.logout();

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
