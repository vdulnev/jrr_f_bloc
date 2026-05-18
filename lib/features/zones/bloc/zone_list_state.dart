import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/app_exception.dart';
import '../data/models/zone.dart';

part 'zone_list_state.freezed.dart';

@freezed
sealed class ZoneListState with _$ZoneListState {
  const factory ZoneListState.loading() = ZoneListLoading;
  const factory ZoneListState.loaded({
    required List<Zone> zones,
    required Zone? activeZone,
  }) = ZoneListLoaded;
  const factory ZoneListState.error({required AppException error}) =
      ZoneListError;
}
