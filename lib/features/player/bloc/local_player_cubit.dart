import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:talker/talker.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/injection.dart';
import '../../library/data/models/track.dart';
import '../../library/data/models/tracks.dart';
import '../../queue/data/repositories/local_queue_repository.dart';
import '../../zones/bloc/active_zone_cubit.dart';
import '../../zones/data/models/zone.dart';
import '../data/models/playback_state.dart';
import '../data/models/player_status.dart';
import '../data/models/repeat_mode.dart';
import '../data/models/shuffle_mode.dart';
import '../services/android_auto_player_service.dart';
import '../services/jrr_audio_handler.dart';
import '../services/local_player_service.dart';
import 'player_controller.dart';
import 'player_state.dart';

String _zoneKey(Zone zone) {
  if (zone.isOffline) return 'offline';
  if (zone.isAndroidAuto) return 'android-auto';
  return 'local';
}

String _kIndexPref(String zoneKey) => 'local_player_${zoneKey}_index';
String _kPosMsPref(String zoneKey) => 'local_player_${zoneKey}_position_ms';
const _kVolumePref = 'local_player_volume';

/// Owns local (just_audio) playback. Emits a [PlayerSnapshot] view derived
/// from the service's position / state / sequence / volume / duration
/// streams. Persists the per-zone queue, current index, and position so
/// playback resumes after relaunch.
///
/// Phase 8 wires the downloads-set listener (so newly downloaded tracks
/// swap streaming URLs to local file paths). Phase 10 wires the Android
/// Auto sub-handler swap.
class LocalPlayerCubit extends Cubit<PlayerSnapshot>
    implements PlayerController {
  final LocalPlayerService _service;
  final ActiveZoneCubit _activeZone;
  final LocalQueueRepository _queueRepo;
  final SharedPreferences _prefs;
  final Talker _talker;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<SequenceState?>? _sequenceSub;
  StreamSubscription<double>? _volumeSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Zone?>? _zoneSub;
  StreamSubscription<SequenceState?>? _persistSub;
  StreamSubscription<Duration>? _persistPositionSub;
  StreamSubscription<double>? _persistVolumeSub;

  Duration _position = Duration.zero;
  Duration? _duration = Duration.zero;
  double _volume = 1.0;
  PlayerState _playerState = PlayerState(false, ProcessingState.idle);
  SequenceState? _sequenceState;
  String _currentZoneKey = '';
  int? _lastSavedIndex;
  List<int>? _lastSavedKeys;

  LocalPlayerCubit({
    required LocalPlayerService service,
    required ActiveZoneCubit activeZone,
    required LocalQueueRepository queueRepository,
    required SharedPreferences prefs,
    required Talker talker,
  }) : _service = service,
       _activeZone = activeZone,
       _queueRepo = queueRepository,
       _prefs = prefs,
       _talker = talker,
       super(const PlayerSnapshot.data(status: null)) {
    _positionSub = _service.positionStream.listen(
      (p) {
        _position = p;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlayerCubit] positionStream', e, st),
    );
    _stateSub = _service.playerStateStream.listen(
      (s) {
        _playerState = s;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlayerCubit] playerStateStream', e, st),
    );
    _sequenceSub = _service.sequenceStateStream.listen(
      (s) {
        _sequenceState = s;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlayerCubit] sequenceStateStream', e, st),
    );
    _volumeSub = _service.volumeStream.listen(
      (v) {
        _volume = v;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlayerCubit] volumeStream', e, st),
    );
    _durationSub = _service.durationStream.listen(
      (d) {
        _duration = d;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlayerCubit] durationStream', e, st),
    );
    _zoneSub = _activeZone.stream.listen(_onZoneChanged);

    // Persist sequence + scalar state. setTracks() replays the same sequence
    // on first load, so guard against echoing it back to storage.
    _persistSub = _service.sequenceStateStream.listen((seq) async {
      if (_currentZoneKey.isEmpty) return;
      final keys = seq?.sequence
              .map((s) => s.tag)
              .whereType<Track>()
              .map((t) => t.fileKey)
              .toList() ??
          const <int>[];
      final index = seq?.currentIndex ?? -1;
      if (_listEquals(keys, _lastSavedKeys) && _lastSavedIndex == index) {
        return;
      }
      _lastSavedKeys = List.of(keys);
      _lastSavedIndex = index;
      final tracks = Tracks(
        tracks: seq?.sequence
                .map((s) => s.tag)
                .whereType<Track>()
                .toList() ??
            const <Track>[],
      );
      await _queueRepo.setTracks(_currentZoneKey, tracks);
      if (index >= 0) {
        await _prefs.setInt(_kIndexPref(_currentZoneKey), index);
      }
    });
    _persistPositionSub = _service.positionStream.listen((pos) {
      if (_currentZoneKey.isEmpty) return;
      _prefs.setInt(_kPosMsPref(_currentZoneKey), pos.inMilliseconds);
    });
    _persistVolumeSub = _service.volumeStream.listen((vol) {
      _prefs.setDouble(_kVolumePref, vol);
    });

    _onZoneChanged(_activeZone.state);
    _recompute();
  }

  Future<void> _onZoneChanged(Zone? zone) async {
    // Pipe system controls (lock screen / notification) to whichever sub-
    // handler matches the zone. Manual user-driven zone picks land here;
    // AndroidAutoSessionService also calls switchTo when the car binds.
    if (getIt.isRegistered<JrrAudioHandler>()) {
      final handler = getIt<JrrAudioHandler>();
      if (zone?.isAndroidAuto == true) {
        if (getIt.isRegistered<AndroidAutoPlayerService>()) {
          handler.switchTo(getIt<AndroidAutoPlayerService>());
        }
      } else {
        handler.switchTo(_service);
      }
    }

    if (zone == null ||
        (!zone.isLocal && !zone.isOffline && !zone.isAndroidAuto)) {
      _recompute();
      return;
    }
    final key = _zoneKey(zone);
    if (key == _currentZoneKey) {
      _recompute();
      return;
    }
    _currentZoneKey = key;
    _lastSavedKeys = null;
    _lastSavedIndex = null;
    await _loadQueue(key);
    _recompute();
  }

  Future<void> _loadQueue(String zoneKey) async {
    _talker.info('[LocalPlayerCubit] Loading persisted queue for $zoneKey');
    final tracksResult = await _queueRepo.getTracks(zoneKey);
    final tracks = tracksResult.match((_) => Tracks.empty, (t) => t);
    await _service.stop();
    await _service.setTracks(tracks);
    _lastSavedKeys = tracks.tracks.map((t) => t.fileKey).toList();

    final savedIndex = _prefs.getInt(_kIndexPref(zoneKey)) ?? -1;
    final savedPosMs = _prefs.getInt(_kPosMsPref(zoneKey)) ?? 0;
    if (tracks.isNotEmpty && savedIndex >= 0 && savedIndex < tracks.length) {
      _lastSavedIndex = savedIndex;
      await _service.seekTo(savedPosMs, index: savedIndex);
    }

    final savedVolume = _prefs.getDouble(_kVolumePref);
    if (savedVolume != null) await _service.setVolume(savedVolume);
  }

  static bool _listEquals(List<int>? a, List<int>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _recompute() {
    final zone = _activeZone.state;
    if (zone == null ||
        (!zone.isLocal && !zone.isOffline && !zone.isAndroidAuto)) {
      emit(const PlayerSnapshot.data(status: null));
      return;
    }
    emit(PlayerSnapshot.data(status: _calculate(zone)));
  }

  PlayerStatus _calculate(Zone zone) {
    final seq = _sequenceState;
    final currentIndex = seq?.currentIndex ?? -1;
    final sequence = seq?.sequence ?? const [];
    final currentTrack = (currentIndex >= 0 && currentIndex < sequence.length)
        ? sequence[currentIndex].tag as Track?
        : null;
    final processing = _playerState.processingState;
    final playing = _playerState.playing;

    final state = processing == ProcessingState.idle
        ? PlaybackState.stopped
        : playing
        ? PlaybackState.playing
        : PlaybackState.paused;

    String statusText = '';
    if (processing == ProcessingState.buffering) statusText = 'Buffering...';
    if (processing == ProcessingState.loading) statusText = 'Loading...';

    return PlayerStatus(
      zoneId: zone.id,
      zoneName: zone.name,
      state: state,
      fileKey: currentTrack?.fileKey ?? -1,
      positionMs: _position.inMilliseconds,
      durationMs: _duration?.inMilliseconds ?? 0,
      positionDisplay: _fmt(_position),
      playingNowPosition: currentIndex,
      playingNowTracks: sequence.length,
      playingNowPositionDisplay:
          currentIndex > -1 ? '${currentIndex + 1} of ${sequence.length}' : '',
      playingNowChangeCounter: 0,
      volume: _volume,
      volumeDisplay: '${(_volume * 100).toInt()}%',
      isMuted: _volume == 0,
      name: currentTrack?.name ?? '',
      artist: currentTrack?.artist ?? '',
      album: currentTrack?.album ?? '',
      imageUrl: currentTrack?.imageUrl ?? '',
      status: statusText,
      shuffleMode:
          (seq?.shuffleModeEnabled ?? false) ? ShuffleMode.on : ShuffleMode.off,
      repeatMode: switch (seq?.loopMode ?? LoopMode.off) {
        LoopMode.off => RepeatMode.off,
        LoopMode.one => RepeatMode.track,
        LoopMode.all => RepeatMode.playlist,
      },
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ---- PlayerController ----------------------------------------------------

  @override
  Future<void> playPause() => _service.playPause();

  @override
  Future<void> stop({Zone? zoneToRun}) => _service.stop();

  @override
  Future<void> next() async => _service.next();

  @override
  Future<void> previous() async => _service.previous();

  @override
  Future<void> seekTo(int positionMs) => _service.seekTo(positionMs);

  @override
  Future<void> setVolume(double level) => _service.setVolume(level);

  @override
  Future<void> playByIndex(int index) => _service.playByIndex(index);

  @override
  Future<void> toggleMute() async {
    final muted = state is PlayerData &&
        (state as PlayerData).status?.isMuted == true;
    await _service.setMute(!muted);
  }

  @override
  Future<void> toggleShuffle() async {
    final current = (state is PlayerData)
        ? (state as PlayerData).status?.shuffleMode ?? ShuffleMode.off
        : ShuffleMode.off;
    final next = current == ShuffleMode.off ? ShuffleMode.on : ShuffleMode.off;
    await _service.setShuffle(next);
  }

  @override
  Future<void> cycleRepeat() async {
    final current = (state is PlayerData)
        ? (state as PlayerData).status?.repeatMode ?? RepeatMode.off
        : RepeatMode.off;
    final next = switch (current) {
      RepeatMode.off => RepeatMode.playlist,
      RepeatMode.playlist => RepeatMode.track,
      RepeatMode.track => RepeatMode.off,
    };
    await _service.setRepeat(next);
  }

  @override
  Future<void> playNow(Tracks tracks) => _service.playNow(tracks);

  @override
  Future<void> playNext(Tracks tracks) async {
    final currentIndex = _sequenceState?.currentIndex ?? -1;
    await _service.insertTracksAt(tracks: tracks, index: currentIndex + 1);
  }

  @override
  Future<void> addToQueue(Tracks tracks) => _service.addToQueue(tracks);

  @override
  Future<void> refresh() async {
    // State pushes via streams; nothing to pull.
  }

  /// Queue ops not part of [PlayerController] — used by the queue screen.
  Future<void> setTracks(Tracks tracks) => _service.setTracks(tracks);
  Future<void> moveTrack(int source, int target) =>
      _service.moveTrack(source, target);
  Future<void> removeTrack(int index) => _service.removeTrack(index);

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _stateSub?.cancel();
    await _sequenceSub?.cancel();
    await _volumeSub?.cancel();
    await _durationSub?.cancel();
    await _zoneSub?.cancel();
    await _persistSub?.cancel();
    await _persistPositionSub?.cancel();
    await _persistVolumeSub?.cancel();
    return super.close();
  }
}
