import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../zones/bloc/active_zone_cubit.dart';
import '../../zones/data/models/zone.dart';
import 'local_player_cubit.dart';
import 'mcws_player_bloc.dart';
import 'player_state.dart';

/// Unified read-only view of the active player. Routes the [PlayerSnapshot]
/// stream from either [McwsPlayerBloc] (real MCWS zone) or
/// [LocalPlayerCubit] (Local / Offline / Android Auto) based on the
/// currently active zone.
class PlayerCubit extends Cubit<PlayerSnapshot> {
  final McwsPlayerBloc _mcws;
  final LocalPlayerCubit _local;
  final ActiveZoneCubit _activeZone;

  StreamSubscription<PlayerSnapshot>? _mcwsSub;
  StreamSubscription<PlayerSnapshot>? _localSub;
  StreamSubscription<Zone?>? _zoneSub;

  PlayerCubit({
    required McwsPlayerBloc mcws,
    required LocalPlayerCubit local,
    required ActiveZoneCubit activeZone,
  }) : _mcws = mcws,
       _local = local,
       _activeZone = activeZone,
       super(const PlayerSnapshot.loading()) {
    _mcwsSub = _mcws.stream.listen(_onMcws);
    _localSub = _local.stream.listen(_onLocal);
    _zoneSub = _activeZone.stream.listen((_) => _emitCurrent());
    _emitCurrent();
  }

  bool get _isLocalLike {
    final z = _activeZone.state;
    return z == null || z.isLocal || z.isOffline || z.isAndroidAuto;
  }

  void _onMcws(PlayerSnapshot s) {
    if (!_isLocalLike) emit(s);
  }

  void _onLocal(PlayerSnapshot s) {
    if (_isLocalLike) emit(s);
  }

  void _emitCurrent() {
    emit(_isLocalLike ? _local.state : _mcws.state);
  }

  @override
  Future<void> close() async {
    await _mcwsSub?.cancel();
    await _localSub?.cancel();
    await _zoneSub?.cancel();
    return super.close();
  }
}
