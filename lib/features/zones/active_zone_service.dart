import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import 'data/models/zone.dart';
import 'data/repositories/zone_repository.dart';

/// Tracks which zone the user is targeting. State is the active zone or
/// `null` when none has been chosen yet (e.g. zone list still loading).
///
/// Persists the active zone's GUID under [kActiveZoneGuidKey] so the same
/// zone is restored on relaunch. Lives outside the bloc tree so other
/// services / blocs can observe it without coupling to widget lifecycle.
class ActiveZoneService {
  final SharedPreferences _prefs;
  final Talker _talker;

  final StreamController<Zone?> _controller =
      StreamController<Zone?>.broadcast();
  Zone? _state;

  ActiveZoneService({required SharedPreferences prefs, required Talker talker})
    : _prefs = prefs,
      _talker = talker;

  Zone? get state => _state;
  Stream<Zone?> get stream => _controller.stream;

  void _emit(Zone? next) {
    if (_state == next) return;
    _state = next;
    _controller.add(next);
  }

  /// Called by `ZonesCubit` whenever a fresh zone list arrives. Restores
  /// the previously saved zone, falls back to the first zone, or clears
  /// state if the list is empty.
  void onZonesLoaded(List<Zone> zones) {
    if (zones.isEmpty) {
      clear();
      return;
    }
    final savedGuid = _prefs.getString(kActiveZoneGuidKey);
    final next = savedGuid != null
        ? zones.firstWhere(
            (z) => z.guid == savedGuid,
            orElse: () => zones.first,
          )
        : zones.first;
    _talker.debug(
      '[ActiveZoneService] Resolved active zone ${next.name} '
      '(savedGuid=$savedGuid)',
    );
    _emitAndPersist(next);
  }

  void setZone(Zone zone) {
    _talker.debug('[ActiveZoneService] setZone ${zone.name}');
    _emitAndPersist(zone);
  }

  void clear() {
    if (_state == null) return;
    _talker.debug('[ActiveZoneService] cleared');
    _emit(null);
    _prefs.remove(kActiveZoneGuidKey);
  }

  void _emitAndPersist(Zone zone) {
    _emit(zone);
    _prefs.setString(kActiveZoneGuidKey, zone.guid);
  }

  Future<void> dispose() async => _controller.close();
}
