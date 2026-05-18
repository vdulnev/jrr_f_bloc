import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' show SequenceState;
import 'package:talker/talker.dart';

import '../../library/data/models/track.dart';
import '../../library/data/models/tracks.dart';
import '../../player/bloc/player_cubit.dart';
import '../../player/bloc/player_state.dart';
import '../../player/local_playback_service.dart';
import '../../player/services/local_player_service.dart';
import '../../zones/active_zone_service.dart';
import '../../zones/data/models/zone.dart';
import '../data/repositories/queue_repository.dart';
import 'queue_state.dart';

/// Tracks the Playing Now queue for the active zone.
///
/// MCWS branch: refreshes whenever [PlayerCubit]'s
/// `playingNowChangeCounter` changes (spec §5.2).
/// Local branch: subscribes to [LocalPlayerService.sequenceStateStream]
/// and translates IndexedAudioSource tags into Tracks.
class QueueCubit extends Cubit<QueueState> {
  final QueueRepository _repo;
  final LocalPlayerService _service;
  final LocalPlaybackService _localPlayer;
  final ActiveZoneService _activeZone;
  final PlayerCubit _player;
  final Talker _talker;

  StreamSubscription<Zone?>? _zoneSub;
  StreamSubscription<PlayerSnapshot>? _playerSub;
  StreamSubscription<SequenceState?>? _localSeqSub;

  int _lastChangeCounter = -1;

  QueueCubit({
    required QueueRepository repository,
    required LocalPlayerService service,
    required LocalPlaybackService localPlayer,
    required ActiveZoneService activeZone,
    required PlayerCubit player,
    required Talker talker,
  }) : _repo = repository,
       _service = service,
       _localPlayer = localPlayer,
       _activeZone = activeZone,
       _player = player,
       _talker = talker,
       super(const QueueState.loading()) {
    _zoneSub = _activeZone.stream.listen((_) => _onAnyChange());
    _playerSub = _player.stream.listen(_onPlayerSnapshot);
    _localSeqSub = _service.sequenceStateStream.listen((seq) {
      if (_isLocalLike) _emitLocal(seq);
    });
    _onAnyChange();
  }

  bool get _isLocalLike {
    final z = _activeZone.state;
    return z != null && (z.isLocal || z.isOffline || z.isAndroidAuto);
  }

  void _onPlayerSnapshot(PlayerSnapshot snap) {
    if (_isLocalLike) return; // Local path comes from the sequence stream.
    final counter = switch (snap) {
      PlayerData(:final status) => status?.playingNowChangeCounter ?? 0,
      _ => _lastChangeCounter,
    };
    if (counter != _lastChangeCounter) {
      _lastChangeCounter = counter;
      _refreshRemote();
    }
  }

  void _onAnyChange() {
    final zone = _activeZone.state;
    if (zone == null) {
      emit(const QueueState.loaded(tracks: Tracks.empty));
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
    emit(QueueState.loaded(tracks: Tracks(tracks: tracks)));
  }

  Future<void> _refreshRemote() async {
    final zone = _activeZone.state;
    if (zone == null || _isLocalLike) return;
    final result = await _repo.getQueue(zone.id);
    result.fold((e) {
      _talker.warning('[QueueCubit] getQueue failed: $e');
      emit(QueueState.error(error: e));
    }, (tracks) => emit(QueueState.loaded(tracks: tracks)));
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

  @override
  Future<void> close() async {
    await _zoneSub?.cancel();
    await _playerSub?.cancel();
    await _localSeqSub?.cancel();
    return super.close();
  }
}
