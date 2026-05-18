import 'dart:async';

import '../zones/active_zone_service.dart';
import 'bloc/player_state.dart';
import 'local_playback_service.dart';
import 'mcws_player_service.dart';

/// Unified read-only view of the active player. Routes the [PlayerSnapshot]
/// stream from either [McwsPlayerService] (real MCWS zone) or
/// [LocalPlaybackService] (Local / Offline / Android Auto) based on the
/// currently active zone.
class PlayerService {
  final McwsPlayerService _mcws;
  final LocalPlaybackService _local;
  final ActiveZoneService _activeZone;

  PlayerSnapshot _lastState = const PlayerSnapshot.loading();
  PlayerSnapshot get state => _lastState;

  final _controller = StreamController<PlayerSnapshot>.broadcast();
  Stream<PlayerSnapshot> get stream => _controller.stream;

  StreamSubscription<PlayerSnapshot>? _mcwsSub;
  StreamSubscription<PlayerSnapshot>? _localSub;
  StreamSubscription<dynamic>? _zoneSub;

  PlayerService({
    required McwsPlayerService mcws,
    required LocalPlaybackService local,
    required ActiveZoneService activeZone,
  }) : _mcws = mcws,
       _local = local,
       _activeZone = activeZone {
    _mcwsSub = _mcws.stream.listen((s) {
      if (!_isLocalLike) _emit(s);
    });
    _localSub = _local.stream.listen((s) {
      if (_isLocalLike) _emit(s);
    });
    _zoneSub = _activeZone.stream.listen((_) => _emit(_calculateState()));
    _emit(_calculateState());
  }

  bool get _isLocalLike {
    final z = _activeZone.state;
    return z == null || z.isLocal || z.isOffline || z.isAndroidAuto;
  }

  PlayerSnapshot _calculateState() {
    return _isLocalLike ? _local.state : _mcws.state;
  }

  void _emit(PlayerSnapshot next) {
    if (_lastState != next) {
      _lastState = next;
      _controller.add(next);
    }
  }

  void dispose() {
    _mcwsSub?.cancel();
    _localSub?.cancel();
    _zoneSub?.cancel();
    _controller.close();
  }
}
