import 'dart:async';

import 'package:just_audio/just_audio.dart' show SequenceState;
import 'package:talker/talker.dart';

import '../library/data/models/track.dart';
import '../library/data/models/tracks.dart';
import '../player/bloc/player_state.dart';
import '../player/local_playback_service.dart';
import '../player/player_service.dart';
import '../player/services/local_player_service.dart';
import '../zones/active_zone_service.dart';
import '../zones/data/models/zone.dart';
import 'bloc/queue_state.dart';
import 'data/repositories/queue_repository.dart';

/// Owns the Playing Now queue snapshot for the active zone. Replaces
/// `QueueCubit`. Subscribed to by [QueueScreenCubit].
///
/// MCWS branch: refreshes whenever [PlayerService]'s
/// `playingNowChangeCounter` changes (spec §5.2).
/// Local branch: subscribes to [LocalPlayerService.sequenceStateStream]
/// and translates IndexedAudioSource tags into Tracks.
class QueueService {
  final QueueRepository _repo;
  final LocalPlayerService _service;
  final LocalPlaybackService _localPlayer;
  final ActiveZoneService _activeZone;
  final PlayerService _player;
  final Talker _talker;

  final _controller = StreamController<QueueState>.broadcast();
  StreamSubscription<Zone?>? _zoneSub;
  StreamSubscription<PlayerSnapshot>? _playerSub;
  StreamSubscription<SequenceState?>? _localSeqSub;

  QueueState _state = const QueueState.loading();
  int _lastChangeCounter = -1;

  QueueService({
    required QueueRepository repository,
    required LocalPlayerService service,
    required LocalPlaybackService localPlayer,
    required ActiveZoneService activeZone,
    required PlayerService player,
    required Talker talker,
  }) : _repo = repository,
       _service = service,
       _localPlayer = localPlayer,
       _activeZone = activeZone,
       _player = player,
       _talker = talker {
    _zoneSub = _activeZone.stream.listen((_) => _onAnyChange());
    _playerSub = _player.stream.listen(_onPlayerSnapshot);
    _localSeqSub = _service.sequenceStateStream.listen((seq) {
      if (_isLocalLike) _emitLocal(seq);
    });
    _onAnyChange();
  }

  QueueState get state => _state;
  Stream<QueueState> get stream => _controller.stream;

  void _emit(QueueState next) {
    _state = next;
    _controller.add(next);
  }

  bool get _isLocalLike {
    final z = _activeZone.state;
    return z != null && (z.isLocal || z.isOffline || z.isAndroidAuto);
  }

  void _onPlayerSnapshot(PlayerSnapshot snap) {
    final status = snap.mapOrNull(data: (d) => d.status);
    final counter = status?.playingNowChangeCounter ?? 0;

    if (!_isLocalLike && counter != _lastChangeCounter) {
      _lastChangeCounter = counter;
      _refreshRemote();
    } else {
      _updateIndex(status?.playingNowPosition ?? -1);
    }
  }

  void _updateIndex(int index) {
    if (_state is QueueLoaded) {
      final s = _state as QueueLoaded;
      if (s.currentIndex != index) {
        _emit(s.copyWith(currentIndex: index));
      }
    }
  }

  void _onAnyChange() {
    final zone = _activeZone.state;
    if (zone == null) {
      _emit(const QueueState.loaded(tracks: Tracks.empty, currentIndex: -1));
      return;
    }
    if (_isLocalLike) {
      _emitLocal(_service.sequenceState);
    } else {
      _lastChangeCounter = -1;
      _refreshRemote();
    }
  }

  void _emitLocal(SequenceState? seq) {
    final tracks =
        seq?.sequence.map((src) => src.tag).whereType<Track>().toList() ??
        const <Track>[];
    _emit(
      QueueState.loaded(
        tracks: Tracks(tracks: tracks),
        currentIndex: seq?.currentIndex ?? -1,
      ),
    );
  }

  Future<void> _refreshRemote() async {
    final zone = _activeZone.state;
    if (zone == null || _isLocalLike) return;
    final result = await _repo.getQueue(zone.id);
    final status = _player.state.mapOrNull(data: (d) => d.status);
    result.fold(
      (e) {
        _talker.warning('[QueueService] getQueue failed: $e');
        _emit(QueueState.error(error: e));
      },
      (tracks) => _emit(
        QueueState.loaded(
          tracks: tracks,
          currentIndex: status?.playingNowPosition ?? -1,
        ),
      ),
    );
  }

  /// Force a refresh — useful after a command that doesn't bump the
  /// change counter (e.g. when the user pulls to refresh).
  Future<void> refresh() async {
    if (_isLocalLike) {
      _emitLocal(_service.sequenceState);
    } else {
      await _refreshRemote();
    }
  }

  Future<void> removeItem(int index) async {
    final zone = _activeZone.state;
    if (zone == null) return;
    if (_isLocalLike) {
      await _localPlayer.removeTrack(index);
    } else {
      await _repo.removeItem(zone.id, index);
      await _refreshRemote();
    }
  }

  Future<void> moveItem(int source, int target) async {
    final zone = _activeZone.state;
    if (zone == null) return;
    if (_isLocalLike) {
      await _localPlayer.moveTrack(source, target);
    } else {
      await _repo.moveItem(zone.id, source, target);
      await _refreshRemote();
    }
  }

  Future<void> clearQueue() async {
    final zone = _activeZone.state;
    if (zone == null) return;
    if (_isLocalLike) {
      await _localPlayer.setTracks(Tracks.empty);
    } else {
      await _repo.clearQueue(zone.id);
      await _refreshRemote();
    }
  }

  Future<void> dispose() async {
    await _zoneSub?.cancel();
    await _playerSub?.cancel();
    await _localSeqSub?.cancel();
    await _controller.close();
  }
}
