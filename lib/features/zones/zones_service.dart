import 'dart:async';

import 'package:talker/talker.dart';

import '../../core/error/app_exception.dart';
import '../connection/bloc/session_state.dart';
import '../connection/session_service.dart';
import 'active_zone_service.dart';
import 'bloc/zones_state.dart';
import 'data/models/zone.dart';
import 'data/repositories/zone_repository.dart';

/// Owns the zone-list snapshot and the 30 s polling timer. Replaces
/// `ZonesCubit`. Subscribed to by `ZoneListCubit` (screen companion);
/// `ActiveZoneService` still gets seeded via `onZonesLoaded` after
/// each fetch.
class ZonesService {
  final ZoneRepository _repo;
  final SessionService _session;
  final ActiveZoneService _activeZone;
  final Talker _talker;

  static const _pollInterval = Duration(seconds: 30);

  final _controller = StreamController<ZonesState>.broadcast();
  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<Zone?>? _activeZoneSub;
  Timer? _timer;

  ZonesState _state = const ZonesState.loading();

  ZonesService({
    required ZoneRepository repository,
    required SessionService session,
    required ActiveZoneService activeZone,
    required Talker talker,
  }) : _repo = repository,
       _session = session,
       _activeZone = activeZone,
       _talker = talker {
    _sessionSub = _session.stream.listen(_onSessionChanged);
    _activeZoneSub = _activeZone.stream.listen(_onActiveZoneChanged);
    _onSessionChanged(_session.state);
  }

  ZonesState get state => _state;
  Stream<ZonesState> get stream => _controller.stream;

  AppException? get error =>
      _state is ZonesError ? (_state as ZonesError).error : null;

  void _emit(ZonesState next) {
    _state = next;
    _controller.add(next);
  }

  void _onSessionChanged(SessionState state) {
    switch (state) {
      case Authenticated():
        refresh();
        _restartTimer();
      case Restoring() || Unauthenticated():
        _stopTimer();
        _emit(const ZonesState.loading());
    }
  }

  void _onActiveZoneChanged(Zone? zone) {
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
        _talker.warning('[ZonesService] getZones failed: $e');
        _emit(ZonesState.error(error: e));
      },
      (zones) {
        _emit(ZonesState.loaded(zones: zones));
        _activeZone.onZonesLoaded(zones);
      },
    );
  }

  void _restartTimer() {
    _stopTimer();
    if (_activeZone.state?.isOffline == true) return;
    _timer = Timer.periodic(_pollInterval, (_) {
      _talker.debug('[ZonesService] Tick — refreshing zone list');
      refresh();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void pause() => _stopTimer();

  void resume() {
    if (_session.state is Authenticated) {
      _restartTimer();
    }
  }

  Future<void> dispose() async {
    _stopTimer();
    await _sessionSub?.cancel();
    await _activeZoneSub?.cancel();
    await _controller.close();
  }
}
