import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../library/data/models/track.dart';
import '../library/data/models/tracks.dart';
import '../offline/data/models/downloaded_track.dart';
import '../offline/data/repositories/downloads_repository.dart';
import '../queue/data/repositories/local_queue_repository.dart';
import '../zones/active_zone_service.dart';
import '../zones/data/models/zone.dart';
import 'bloc/player_controller.dart';
import 'bloc/player_state.dart';
import 'data/models/playback_state.dart';
import 'data/models/player_status.dart';
import 'data/models/repeat_mode.dart';
import 'data/models/shuffle_mode.dart';
import 'services/android_auto_player_service.dart';
import 'services/jrr_audio_handler.dart';
import 'services/local_player_service.dart';
import '../../core/di/injection.dart';

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
/// Subscribes to the downloads-set listener so newly downloaded tracks
/// swap streaming URLs to local file paths.
class LocalPlaybackService implements PlayerController {
  final LocalPlayerService _service;
  final ActiveZoneService _activeZone;
  final LocalQueueRepository _queueRepo;
  final DownloadsRepository _downloadsRepo;
  final SharedPreferences _prefs;
  final Talker _talker;

  PlayerSnapshot _state = const PlayerSnapshot.data(status: null);
  PlayerSnapshot get state => _state;

  final _controller = StreamController<PlayerSnapshot>.broadcast();
  Stream<PlayerSnapshot> get stream => _controller.stream;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<SequenceState?>? _sequenceSub;
  StreamSubscription<double>? _volumeSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Zone?>? _zoneSub;
  StreamSubscription<SequenceState?>? _persistSub;
  StreamSubscription<Duration>? _persistPositionSub;
  StreamSubscription<double>? _persistVolumeSub;
  StreamSubscription<List<DownloadedTrack>>? _downloadsSub;
  Set<int>? _lastDownloadedKeys;
  bool _isReloading = false;
  bool _reloadQueuedDuringReload = false;

  Duration _position = Duration.zero;
  Duration? _duration = Duration.zero;
  double _volume = 1.0;
  PlayerState _playerState = PlayerState(false, ProcessingState.idle);
  SequenceState? _sequenceState;
  String _currentZoneKey = '';
  int? _lastSavedIndex;
  List<int>? _lastSavedKeys;

  LocalPlaybackService({
    required LocalPlayerService service,
    required ActiveZoneService activeZone,
    required LocalQueueRepository queueRepository,
    required DownloadsRepository downloadsRepository,
    required SharedPreferences prefs,
    required Talker talker,
  }) : _service = service,
       _activeZone = activeZone,
       _queueRepo = queueRepository,
       _downloadsRepo = downloadsRepository,
       _prefs = prefs,
       _talker = talker {
    _positionSub = _service.positionStream.listen(
      (p) {
        _position = p;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlaybackService] positionStream', e, st),
    );
    _stateSub = _service.playerStateStream.listen(
      (s) {
        _playerState = s;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlaybackService] playerStateStream', e, st),
    );
    _sequenceSub = _service.sequenceStateStream.listen(
      (s) {
        _sequenceState = s;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlaybackService] sequenceStateStream', e, st),
    );
    _volumeSub = _service.volumeStream.listen(
      (v) {
        _volume = v;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlaybackService] volumeStream', e, st),
    );
    _durationSub = _service.durationStream.listen(
      (d) {
        _duration = d;
        _recompute();
      },
      onError: (Object e, StackTrace st) =>
          _talker.error('[LocalPlaybackService] durationStream', e, st),
    );
    _zoneSub = _activeZone.stream.listen(_onZoneChanged);

    // Persist sequence + scalar state. setTracks() replays the same sequence
    // on first load, so guard against echoing it back to storage.
    _persistSub = _service.sequenceStateStream.listen((seq) async {
      if (_currentZoneKey.isEmpty) return;
      final keys =
          seq?.sequence
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
        tracks:
            seq?.sequence.map((s) => s.tag).whereType<Track>().toList() ??
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

    // When a download finishes (or is removed), tracks already in the
    // queue may need to swap streaming URLs ↔ local files. We only
    // reload if the current queue overlaps with the changed set.
    _downloadsSub = _downloadsRepo.watchDownloadedTracks().listen((tracks) {
      _onDownloadsChanged(tracks);
    });

    _onZoneChanged(_activeZone.state);
    _recompute();
  }

  void _emit(PlayerSnapshot next) {
    if (_state != next) {
      _state = next;
      _controller.add(next);
    }
  }

  void _onDownloadsChanged(List<DownloadedTrack> downloaded) {
    final next = downloaded.map((t) => t.fileKey).toSet();
    final prev = _lastDownloadedKeys;
    _lastDownloadedKeys = next;
    if (prev == null) return; // First snapshot — nothing to reload yet.

    final added = next.difference(prev);
    final removed = prev.difference(next);
    if (added.isEmpty && removed.isEmpty) return;

    final queueKeys = _service.sequence
        .map((s) => s.tag)
        .whereType<Track>()
        .map((t) => t.fileKey)
        .toSet();
    if (queueKeys.isEmpty) return;

    final addedRelevant = added.intersection(queueKeys);
    final removedRelevant = removed.intersection(queueKeys);
    if (addedRelevant.isEmpty && removedRelevant.isEmpty) return;

    if (_currentZoneKey == 'offline' && removedRelevant.isNotEmpty) {
      _talker.info(
        '[LocalPlaybackService] [offline] ${removedRelevant.length} deleted '
        '— dropping from queue (no streaming fallback)',
      );
      _removeFromQueue(removedRelevant);
      return;
    }

    _talker.info(
      '[LocalPlaybackService] [$_currentZoneKey] downloads changed '
      '(+${addedRelevant.length} / -${removedRelevant.length}) — reloading queue',
    );
    unawaited(_reloadQueueWithCurrentState());
  }

  Future<void> _removeFromQueue(Set<int> fileKeys) async {
    final sequence = _service.sequence;
    for (var i = sequence.length - 1; i >= 0; i--) {
      final tag = sequence[i].tag;
      if (tag is Track && fileKeys.contains(tag.fileKey)) {
        await _service.removeTrack(i);
      }
    }
  }

  /// Tears down and re-loads the current queue so newly-downloaded tracks
  /// switch from streaming URLs to local files (and removed downloads
  /// switch back to streaming, when online). Coalesced so a burst of
  /// downloads triggers at most one in-flight reload.
  Future<void> _reloadQueueWithCurrentState() async {
    if (_isReloading) {
      _reloadQueuedDuringReload = true;
      return;
    }
    _isReloading = true;
    try {
      final seq = _sequenceState;
      if (seq == null) return;
      final wasPlaying = _playerState.playing;
      final currentIndex = seq.currentIndex ?? -1;
      final currentPositionMs = _position.inMilliseconds;
      final tracks = Tracks(
        tracks: seq.sequence.map((s) => s.tag).whereType<Track>().toList(),
      );
      await _service.stop();
      await _service.setTracks(tracks);
      if (currentIndex >= 0 && currentIndex < tracks.length) {
        await _service.seekTo(currentPositionMs, index: currentIndex);
      }
      if (wasPlaying) await _service.play();
    } finally {
      _isReloading = false;
      if (_reloadQueuedDuringReload) {
        _reloadQueuedDuringReload = false;
        scheduleMicrotask(_reloadQueueWithCurrentState);
      }
    }
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
    _talker.info('[LocalPlaybackService] Loading persisted queue for $zoneKey');
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
      _emit(const PlayerSnapshot.data(status: null));
      return;
    }
    _emit(PlayerSnapshot.data(status: _calculate(zone)));
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
      playingNowPositionDisplay: currentIndex > -1
          ? '${currentIndex + 1} of ${sequence.length}'
          : '',
      playingNowChangeCounter: 0,
      volume: _volume,
      volumeDisplay: '${(_volume * 100).toInt()}%',
      isMuted: _volume == 0,
      name: currentTrack?.name ?? '',
      artist: currentTrack?.artist ?? '',
      album: currentTrack?.album ?? '',
      imageUrl: currentTrack?.imageUrl ?? '',
      status: statusText,
      shuffleMode: (seq?.shuffleModeEnabled ?? false)
          ? ShuffleMode.on
          : ShuffleMode.off,
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
    final status = state.mapOrNull(data: (d) => d.status);
    final muted = status?.isMuted == true;
    await _service.setMute(!muted);
  }

  @override
  Future<void> toggleShuffle() async {
    final status = state.mapOrNull(data: (d) => d.status);
    final current = status?.shuffleMode ?? ShuffleMode.off;
    final next = current == ShuffleMode.off ? ShuffleMode.on : ShuffleMode.off;
    await _service.setShuffle(next);
  }

  @override
  Future<void> cycleRepeat() async {
    final status = state.mapOrNull(data: (d) => d.status);
    final current = status?.repeatMode ?? RepeatMode.off;
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

  // ---- Queue Ops -----------------------------------------------------------

  Future<void> setTracks(Tracks tracks) => _service.setTracks(tracks);
  Future<void> moveTrack(int source, int target) =>
      _service.moveTrack(source, target);
  Future<void> removeTrack(int index) => _service.removeTrack(index);

  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _sequenceSub?.cancel();
    _volumeSub?.cancel();
    _durationSub?.cancel();
    _zoneSub?.cancel();
    _persistSub?.cancel();
    _persistPositionSub?.cancel();
    _persistVolumeSub?.cancel();
    _downloadsSub?.cancel();
    _controller.close();
  }
}
