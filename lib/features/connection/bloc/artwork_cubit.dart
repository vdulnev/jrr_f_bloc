import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/connection_repository.dart';
import '../session_service.dart';
import 'artwork_state.dart';
import 'session_state.dart';

/// Surfaces just enough connection state for [ArtworkWidget] to compose
/// a `File/GetImage` URL. Lives in a Cubit so the widget never reaches
/// into `SessionService` or `ConnectionRepository` directly.
class ArtworkCubit extends Cubit<ArtworkState> {
  final SessionService _session;
  final ConnectionRepository _repo;
  StreamSubscription<SessionState>? _sub;

  ArtworkCubit({
    required SessionService session,
    required ConnectionRepository repository,
  }) : _session = session,
       _repo = repository,
       super(_snapshot(session.state, repository)) {
    _sub = _session.stream.listen((_) => emit(_snapshot(_session.state, _repo)));
  }

  static ArtworkState _snapshot(SessionState s, ConnectionRepository r) =>
      switch (s) {
        Authenticated(:final serverInfo) => ArtworkState(
          serverAddress: serverInfo.address,
          token: r.currentToken,
        ),
        _ => const ArtworkState(serverAddress: null, token: null),
      };

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
