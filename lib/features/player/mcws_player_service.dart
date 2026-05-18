import 'dart:async';

import 'package:talker/talker.dart';

import '../connection/bloc/session_state.dart';
import '../connection/session_service.dart';
import '../library/data/models/tracks.dart';
import '../library/data/repositories/library_repository.dart';
import '../zones/active_zone_service.dart';
import '../zones/data/models/zone.dart';
import 'bloc/player_controller.dart';
import 'bloc/player_state.dart';
import 'data/models/playback_state.dart';
import 'data/models/repeat_mode.dart';
import 'data/models/shuffle_mode.dart';
import 'data/repositories/player_repository.dart';

/// Drives MCWS-driven (remote) playback. Owns the adaptive
/// `Playback/Info` polling timer (1s while playing, 5s otherwise).
///
/// Emits [PlayerSnapshot]. Returns `data(null)` whenever the active
/// zone is virtual (Local / Offline / Android Auto) — that branch belongs
/// to [LocalPlaybackService].
class McwsPlayerService implements PlayerController {
  final PlayerRepository _repo;
  final LibraryRepository _library;
  final SessionService _session;
  final ActiveZoneService _activeZone;
  final Talker _talker;

  PlayerSnapshot _state = const PlayerSnapshot.loading();
  PlayerSnapshot get state => _state;

  final _controller = StreamController<PlayerSnapshot>.broadcast();
  Stream<PlayerSnapshot> get stream => _controller.stream;

  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<Zone?>? _activeZoneSub;
  Timer? _timer;
  bool _paused = false;

  McwsPlayerService({
    required PlayerRepository repository,
    required LibraryRepository library,
    required SessionService session,
    required ActiveZoneService activeZone,
    required Talker talker,
  }) : _repo = repository,
       _library = library,
       _session = session,
       _activeZone = activeZone,
       _talker = talker {
    _sessionSub = _session.stream.listen(_evaluatePolling);
    _activeZoneSub = _activeZone.stream.listen(_onZoneChanged);
    _evaluatePolling(_session.state);
  }

  void _emit(PlayerSnapshot next) {
    if (_state != next) {
      _state = next;
      _controller.add(next);
    }
  }

  Zone? get _zone => _activeZone.state;

  bool get _isRemoteZone =>
      _zone != null &&
      !_zone!.isLocal &&
      !_zone!.isOffline &&
      !_zone!.isAndroidAuto;

  void _onZoneChanged(Zone? zone) {
    if (zone == null || !_isRemoteZone) {
      _emit(const PlayerSnapshot.data(status: null));
      _stopTimer();
      return;
    }
    refresh();
    _scheduleNext();
  }

  void _evaluatePolling(SessionState state) {
    switch (state) {
      case Authenticated():
        if (_isRemoteZone && !_paused) _scheduleNext();
      case Restoring() || Unauthenticated():
        _stopTimer();
        _emit(const PlayerSnapshot.loading());
    }
  }

  // ---- Polling -------------------------------------------------------------

  void _scheduleNext() {
    _timer?.cancel();
    final interval =
        state is PlayerData &&
            (state as PlayerData).status?.state == PlaybackState.playing
        ? const Duration(seconds: 1)
        : const Duration(seconds: 5);
    _timer = Timer(interval, _tick);
  }

  Future<void> _tick() async {
    if (_session.state is! Authenticated || !_isRemoteZone || _paused) return;
    await refresh();
    _scheduleNext();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void pause() {
    _paused = true;
    _stopTimer();
  }

  void resume() {
    _paused = false;
    if (_session.state is Authenticated && _isRemoteZone) _scheduleNext();
  }

  // ---- PlayerController ----------------------------------------------------

  @override
  Future<void> refresh() async {
    final zone = _zone;
    if (zone == null || !_isRemoteZone) return;
    final result = await _repo.getPlaybackInfo(zone.id);
    result.fold((e) {
      _talker.warning('[McwsPlayerService] getPlaybackInfo failed: $e');
      _emit(PlayerSnapshot.error(error: e));
    }, (status) => _emit(PlayerSnapshot.data(status: status)));
  }

  @override
  Future<void> playPause() => _runZone((id) => _repo.playPause(id));

  @override
  Future<void> stop({Zone? zoneToRun}) =>
      _runZone((id) => _repo.stop(id), zoneToRun: zoneToRun);

  @override
  Future<void> next() => _runZone((id) => _repo.next(id));

  @override
  Future<void> previous() => _runZone((id) => _repo.previous(id));

  @override
  Future<void> seekTo(int positionMs) =>
      _runZone((id) => _repo.setPosition(id, positionMs));

  @override
  Future<void> setVolume(double level) =>
      _runZone((id) => _repo.setVolume(id, level));

  @override
  Future<void> toggleMute() async {
    final s = _data?.status;
    final isMuted = s?.isMuted ?? false;
    await _runZone((id) => _repo.setMute(id, mute: !isMuted));
  }

  @override
  Future<void> toggleShuffle() async {
    final current = _data?.status?.shuffleMode ?? ShuffleMode.off;
    final nextMode = current == ShuffleMode.off
        ? ShuffleMode.on
        : ShuffleMode.off;
    await _runZone((id) => _repo.setShuffle(id, nextMode));
  }

  @override
  Future<void> cycleRepeat() async {
    final current = _data?.status?.repeatMode ?? RepeatMode.off;
    final nextMode = switch (current) {
      RepeatMode.off => RepeatMode.playlist,
      RepeatMode.playlist => RepeatMode.track,
      RepeatMode.track => RepeatMode.off,
    };
    await _runZone((id) => _repo.setRepeat(id, nextMode));
  }

  @override
  Future<void> playByIndex(int index) =>
      _runZone((id) => _repo.playByIndex(id, index));

  @override
  Future<void> playNow(Tracks tracks) => _runZone(
    (id) => _library.playNow(id, tracks.tracks.map((t) => t.fileKey).toList()),
  );

  @override
  Future<void> playNext(Tracks tracks) => _runZone(
    (id) => _library.playNext(id, tracks.tracks.map((t) => t.fileKey).toList()),
  );

  @override
  Future<void> addToQueue(Tracks tracks) => _runZone(
    (id) =>
        _library.addToQueue(id, tracks.tracks.map((t) => t.fileKey).toList()),
  );

  // ---- Helpers -------------------------------------------------------------

  PlayerData? get _data => state is PlayerData ? state as PlayerData : null;

  Future<void> _runZone(
    Future<dynamic> Function(String zoneId) cmd, {
    Zone? zoneToRun,
  }) async {
    final zone = zoneToRun ?? _zone;
    if (zone == null || zone.isLocal || zone.isOffline || zone.isAndroidAuto) {
      return;
    }
    await cmd(zone.id);
    await refresh();
  }

  void dispose() {
    _stopTimer();
    _sessionSub?.cancel();
    _activeZoneSub?.cancel();
    _controller.close();
  }
}
