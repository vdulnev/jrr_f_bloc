import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/app_exception.dart';
import '../data/models/player_status.dart';

part 'player_state.freezed.dart';

/// Async view of the active player. Mirrors AsyncValue's three states so
/// widgets can switch on it 1:1.
@freezed
sealed class PlayerSnapshot with _$PlayerSnapshot {
  const factory PlayerSnapshot.loading() = PlayerLoading;
  const factory PlayerSnapshot.data({required PlayerStatus? status}) =
      PlayerData;
  const factory PlayerSnapshot.error({required AppException error}) =
      PlayerError;
}
