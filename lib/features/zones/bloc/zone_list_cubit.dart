import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../active_zone_service.dart';
import '../data/models/zone.dart';
import '../zones_service.dart';
import 'zone_list_state.dart';
import 'zones_state.dart';

/// Companion of [ZoneListScreen]. Aggregates the zones list (from
/// [ZonesService]) with the active zone (from [ActiveZoneService]) into a
/// single immutable [ZoneListState] so the screen binds to exactly one
/// cubit.
class ZoneListCubit extends Cubit<ZoneListState> {
  final ZonesService _zones;
  final ActiveZoneService _activeZone;

  StreamSubscription<ZonesState>? _zonesSub;
  StreamSubscription<Zone?>? _activeSub;

  ZoneListCubit({
    required ZonesService zones,
    required ActiveZoneService activeZone,
  }) : _zones = zones,
       _activeZone = activeZone,
       super(_combine(zones.state, activeZone.state)) {
    _zonesSub = _zones.stream.listen(
      (z) => emit(_combine(z, _activeZone.state)),
    );
    _activeSub = _activeZone.stream.listen(
      (a) => emit(_combine(_zones.state, a)),
    );
  }

  static ZoneListState _combine(ZonesState zones, Zone? active) =>
      switch (zones) {
        ZonesLoading() => const ZoneListState.loading(),
        ZonesError(:final error) => ZoneListState.error(error: error),
        ZonesLoaded(:final zones) => ZoneListState.loaded(
          zones: zones,
          activeZone: active,
        ),
      };

  Future<void> refresh() => _zones.refresh();
  void setZone(Zone zone) => _activeZone.setZone(zone);

  @override
  Future<void> close() async {
    await _zonesSub?.cancel();
    await _activeSub?.cancel();
    return super.close();
  }
}
