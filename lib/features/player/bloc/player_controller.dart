import '../../library/data/models/tracks.dart';
import '../../zones/data/models/zone.dart';

/// Common command surface implemented by every concrete player bloc
/// (`LocalPlayerCubit`, `McwsPlayerBloc`). Lets [PlayerControllerCubit]
/// dispatch by zone once and forward each command as a one-liner.
abstract interface class PlayerController {
  Future<void> playPause();
  Future<void> stop({Zone? zoneToRun});
  Future<void> next();
  Future<void> previous();
  Future<void> seekTo(int positionMs);
  Future<void> setVolume(double level);
  Future<void> toggleMute();
  Future<void> toggleShuffle();
  Future<void> playByIndex(int index);
  Future<void> cycleRepeat();
  Future<void> playNow(Tracks tracks);
  Future<void> playNext(Tracks tracks);
  Future<void> addToQueue(Tracks tracks);

  /// Pull-refresh from the underlying transport. No-op for transports
  /// that push state via streams.
  Future<void> refresh();
}
