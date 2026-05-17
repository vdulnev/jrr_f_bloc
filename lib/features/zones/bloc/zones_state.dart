import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/app_exception.dart';
import '../data/models/zone.dart';

part 'zones_state.freezed.dart';

@freezed
sealed class ZonesState with _$ZonesState {
  const factory ZonesState.loading() = ZonesLoading;
  const factory ZonesState.loaded({required List<Zone> zones}) = ZonesLoaded;
  const factory ZonesState.error({required AppException error}) = ZonesError;
}
