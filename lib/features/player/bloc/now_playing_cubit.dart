import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../library/track_lookup_service.dart';
import '../../zones/active_zone_service.dart';
import '../player_service.dart';
import 'now_playing_state.dart';
import 'player_state.dart';

/// Companion of [NowPlayingScreen]. Aggregates the active zone, 
/// the unified player snapshot, and the track-lookup enrichment 
/// into a single immutable state.
class NowPlayingCubit extends Cubit<NowPlayingState> {
  final ActiveZoneService _activeZone;
  final PlayerService _player;
  final TrackLookupService _lookup;

  StreamSubscription<dynamic>? _zoneSub;
  StreamSubscription<PlayerSnapshot>? _playerSub;
  StreamSubscription<dynamic>? _lookupSub;

  int _lastFileKey = -1;

  NowPlayingCubit({
    required ActiveZoneService activeZone,
    required PlayerService player,
    required TrackLookupService lookup,
  }) : _activeZone = activeZone,
       _player = player,
       _lookup = lookup,
       super(const NowPlayingState.loading()) {
    _zoneSub = _activeZone.stream.listen((_) => _recompute());
    _playerSub = _player.stream.listen((snap) {
      final status = snap.mapOrNull(data: (d) => d.status);
      final key = status?.fileKey ?? -1;
      if (key != _lastFileKey && key >= 0) {
        _lastFileKey = key;
        _lookup.lookup(key);
      }
      _recompute();
    });
    _lookupSub = _lookup.stream.listen((_) => _recompute());
    _recompute();
  }

  void _recompute() {
    final zone = _activeZone.state;
    if (zone == null) {
      if (state is! NowPlayingLoading) {
        emit(const NowPlayingState.loading());
      }
      return;
    }

    final status = _player.state.mapOrNull(data: (d) => d.status);
    final track = _lookup.state;

    final next = NowPlayingState.data(
      zone: zone,
      status: status,
      track: track,
    );
    
    if (state != next) emit(next);
  }

  @override
  Future<void> close() async {
    await _zoneSub?.cancel();
    await _playerSub?.cancel();
    await _lookupSub?.cancel();
    return super.close();
  }
}
