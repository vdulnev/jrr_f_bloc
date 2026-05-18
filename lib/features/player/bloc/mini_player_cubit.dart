import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/player_status.dart';
import '../player_command_service.dart';
import '../player_service.dart';
import 'player_state.dart';

typedef MiniPlayerState = ({PlayerStatus? status});

/// Companion of [MiniPlayerPanel]. Forwards the current player status
/// from the unified [PlayerService] and exposes the transport commands
/// the mini-player uses.
class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final PlayerService _player;
  final PlayerCommandService _commands;
  StreamSubscription<PlayerSnapshot>? _sub;

  MiniPlayerCubit({
    required PlayerService player,
    required PlayerCommandService commands,
  }) : _player = player,
       _commands = commands,
       super((status: player.state.mapOrNull(data: (d) => d.status))) {
    _sub = _player.stream.listen((snap) {
      final next = (status: snap.mapOrNull(data: (d) => d.status));
      if (next != state) emit(next);
    });
  }

  Future<void> playPause() => _commands.playPause();
  Future<void> next() => _commands.next();
  Future<void> previous() => _commands.previous();
  Future<void> setVolume(double level) => _commands.setVolume(level);
  Future<void> toggleMute() => _commands.toggleMute();

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
