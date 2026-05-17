import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/mcws_client.dart';
import '../../../connection/data/repositories/connection_repository.dart';
import '../models/zone.dart';
import 'zone_repository.dart';

const _localZones = [Zone.local, Zone.offline];

class ZoneRepositoryImpl implements ZoneRepository {
  /// Appends [Zone.androidAuto] when an Auto session is currently bound.
  /// Phase 10 wires the actual session service; until then the AA zone is
  /// never surfaced from this repository.
  List<Zone> _withAndroidAuto(List<Zone> zones) => zones;

  @override
  Future<Either<AppException, List<Zone>>> getZones() async {
    // If the current session is the synthetic "offline" one, we skip all
    // network calls and only return the Offline zone.
    // We also hide the 'local' zone in this case because without a server
    // it's non-functional (cannot resolve streaming URLs).
    final session = getIt<ConnectionRepository>().currentToken;
    if (session == null) {
      return right(_withAndroidAuto([Zone.offline]));
    }

    final savedGuid = getIt<SharedPreferences>().getString(kActiveZoneGuidKey);
    if (savedGuid == 'offline-zone-guid') {
      return right(_withAndroidAuto(_localZones));
    }

    try {
      final result = await getIt<McwsClient>().getZones();
      return result.fold(
        (e) => right(_withAndroidAuto(_localZones)),
        (zones) => right(_withAndroidAuto([...zones, ..._localZones])),
      );
    } catch (_) {
      return right(_withAndroidAuto(_localZones));
    }
  }

  @override
  Future<Either<AppException, Unit>> setActiveZone(String zoneId) async {
    // Virtual zones (Local/Offline/Android Auto) don't need a server-side
    // setActiveZone call.
    if (zoneId == 'local' || zoneId == 'offline' || zoneId == 'android-auto') {
      return right(unit);
    }

    try {
      return await getIt<McwsClient>().setActiveZone(zoneId);
    } catch (e) {
      return left(AppException.unknown(error: e));
    }
  }
}
