import '../../library/data/models/tracks.dart';
import '../../zones/active_zone_service.dart';
import '../../zones/data/models/zone.dart';
import '../mcws_player_service.dart';
import 'local_player_cubit.dart';
import 'player_controller.dart';

/// Routes player commands to either the local or the MCWS controller based
/// on the currently active zone. Not a Cubit — has no state of its own —
/// but lives in `bloc/` because call sites grab it via `context.read`.
class PlayerControllerCubit implements PlayerController {
  final McwsPlayerService _mcws;
  final LocalPlayerCubit _local;
  final ActiveZoneService _activeZone;

  PlayerControllerCubit({
    required McwsPlayerService mcws,
    required LocalPlayerCubit local,
    required ActiveZoneService activeZone,
  }) : _mcws = mcws,
       _local = local,
       _activeZone = activeZone;

  PlayerController _controllerFor(Zone? zone) {
    final isLocal =
        zone == null || zone.isLocal || zone.isOffline || zone.isAndroidAuto;
    return isLocal ? _local : _mcws;
  }

  PlayerController get _active => _controllerFor(_activeZone.state);

  @override
  Future<void> refresh() => _active.refresh();

  @override
  Future<void> playPause() => _active.playPause();

  @override
  Future<void> next() => _active.next();

  @override
  Future<void> previous() => _active.previous();

  @override
  Future<void> seekTo(int positionMs) => _active.seekTo(positionMs);

  @override
  Future<void> setVolume(double level) => _active.setVolume(level);

  @override
  Future<void> toggleMute() => _active.toggleMute();

  @override
  Future<void> toggleShuffle() => _active.toggleShuffle();

  @override
  Future<void> playByIndex(int index) => _active.playByIndex(index);

  @override
  Future<void> cycleRepeat() => _active.cycleRepeat();

  @override
  Future<void> playNow(Tracks tracks) => _active.playNow(tracks);

  @override
  Future<void> playNext(Tracks tracks) => _active.playNext(tracks);

  @override
  Future<void> addToQueue(Tracks tracks) => _active.addToQueue(tracks);

  @override
  Future<void> stop({Zone? zoneToRun}) =>
      _controllerFor(zoneToRun ?? _activeZone.state).stop(zoneToRun: zoneToRun);
}
