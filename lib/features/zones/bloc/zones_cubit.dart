import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

import '../../../core/error/app_exception.dart';
import '../../connection/bloc/session_cubit.dart';
import '../../connection/bloc/session_state.dart';
import '../data/models/zone.dart';
import '../data/repositories/zone_repository.dart';
import 'active_zone_cubit.dart';
import 'zones_state.dart';

/// Loads the zone list from the server and polls every 30s while the
/// session is authenticated. Suspends polling while the active zone is the
/// synthetic Offline zone (no server to talk to).
class ZonesCubit extends Cubit<ZonesState> {
  final ZoneRepository _repo;
  final SessionCubit _session;
  final ActiveZoneCubit _activeZone;
  final Talker _talker;

  static const _pollInterval = Duration(seconds: 30);

  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<Zone?>? _activeZoneSub;
  Timer? _timer;

  ZonesCubit({
    required ZoneRepository repository,
    required SessionCubit session,
    required ActiveZoneCubit activeZone,
    required Talker talker,
  }) : _repo = repository,
       _session = session,
       _activeZone = activeZone,
       _talker = talker,
       super(const ZonesState.loading()) {
    _sessionSub = _session.stream.listen(_onSessionChanged);
    _activeZoneSub = _activeZone.stream.listen(_onActiveZoneChanged);
    // Seed from current session state — listeners only fire on change.
    _onSessionChanged(_session.state);
  }

  void _onSessionChanged(SessionState state) {
    switch (state) {
      case Authenticated():
        refresh();
        _restartTimer();
      case Restoring() || Unauthenticated():
        _stopTimer();
        emit(const ZonesState.loading());
    }
  }

  void _onActiveZoneChanged(Zone? zone) {
    // Suspend polling when the user picks the Offline zone (server-less).
    if (zone?.isOffline == true) {
      _stopTimer();
    } else if (_session.state is Authenticated && _timer == null) {
      _restartTimer();
    }
  }

  Future<void> refresh() async {
    final result = await _repo.getZones();
    result.fold(
      (e) {
        _talker.warning('[ZonesCubit] getZones failed: $e');
        emit(ZonesState.error(error: e));
      },
      (zones) {
        emit(ZonesState.loaded(zones: zones));
        _activeZone.onZonesLoaded(zones);
      },
    );
  }

  void _restartTimer() {
    _stopTimer();
    if (_activeZone.state?.isOffline == true) return;
    _timer = Timer.periodic(_pollInterval, (_) {
      _talker.debug('[ZonesCubit] Tick — refreshing zone list');
      refresh();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Pause polling without dropping state (e.g. when the app is backgrounded).
  void pause() => _stopTimer();

  /// Resume polling if a session is active.
  void resume() {
    if (_session.state is Authenticated) {
      _restartTimer();
    }
  }

  /// Convenience for callers that don't want to switch on the union.
  AppException? get error =>
      state is ZonesError ? (state as ZonesError).error : null;

  @override
  Future<void> close() async {
    _stopTimer();
    await _sessionSub?.cancel();
    await _activeZoneSub?.cancel();
    return super.close();
  }
}
