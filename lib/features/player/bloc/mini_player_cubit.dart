import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/player_status.dart';
import '../player_service.dart';
import 'player_state.dart';

typedef MiniPlayerState = ({PlayerStatus? status});

/// Companion of [MiniPlayerPanel]. Forwards the current player status
/// from the unified [PlayerService].
class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final PlayerService _player;
  StreamSubscription<PlayerSnapshot>? _sub;

  MiniPlayerCubit({required PlayerService player})
    : _player = player,
      super((status: player.state.mapOrNull(data: (d) => d.status))) {
    _sub = _player.stream.listen((snap) {
      final next = (status: snap.mapOrNull(data: (d) => d.status));
      if (next != state) emit(next);
    });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
