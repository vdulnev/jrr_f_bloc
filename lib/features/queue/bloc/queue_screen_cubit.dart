import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../player/player_command_service.dart';
import '../queue_service.dart';
import 'queue_state.dart';

/// Companion of [QueueScreen]. Mirrors [QueueService.state] and forwards
/// transport / queue mutation commands.
class QueueScreenCubit extends Cubit<QueueState> {
  final QueueService _queue;
  final PlayerCommandService _commands;

  StreamSubscription<QueueState>? _sub;

  QueueScreenCubit({
    required QueueService queue,
    required PlayerCommandService commands,
  }) : _queue = queue,
       _commands = commands,
       super(queue.state) {
    _sub = _queue.stream.listen(emit);
  }

  Future<void> refresh() => _queue.refresh();
  Future<void> removeItem(int index) => _queue.removeItem(index);
  Future<void> clearQueue() => _queue.clearQueue();
  Future<void> playByIndex(int index) => _commands.playByIndex(index);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
