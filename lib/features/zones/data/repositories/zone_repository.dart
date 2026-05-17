import 'package:fpdart/fpdart.dart';

import '../../../../core/error/app_exception.dart';
import '../models/zone.dart';

/// SharedPreferences key for the persisted active zone GUID. Lives in the
/// data layer so repositories can read it without depending on bloc-layer
/// code.
const kActiveZoneGuidKey = 'active_zone_guid';

abstract interface class ZoneRepository {
  Future<Either<AppException, List<Zone>>> getZones();
  Future<Either<AppException, Unit>> setActiveZone(String zoneId);
}
