import '../library/data/models/tracks.dart';
import '../zones/active_zone_service.dart';
import '../zones/data/models/zone.dart';
import 'bloc/player_controller.dart';
import 'local_playback_service.dart';
import 'mcws_player_service.dart';

/// Stateless command sink. Routes transport / queue commands to the
/// MCWS or Local controller based on the currently active zone.
///
/// Registered as a GetIt singleton — companion cubits (and the few
/// widgets without a companion yet) resolve it directly. There is no
/// state to subscribe to; this exists purely to dispatch by zone.
class PlayerCommandService implements PlayerController {
  final McwsPlayerService _mcws;
  final LocalPlaybackService _local;
  final ActiveZoneService _activeZone;

  PlayerCommandService({
    required McwsPlayerService mcws,
    required LocalPlaybackService local,
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
