import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../session_service.dart';
import 'session_state.dart';

/// Companion of [RootScreen]. UI-side observer of [SessionService] —
/// the widget tree never reaches into the service directly. State is
/// exactly [SessionState], no extra fields, no extra streams.
class RootCubit extends Cubit<SessionState> {
  final SessionService _session;
  StreamSubscription<SessionState>? _sub;

  RootCubit({required SessionService session})
    : _session = session,
      super(session.state) {
    _sub = _session.stream.listen(emit);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
