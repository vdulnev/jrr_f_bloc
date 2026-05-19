import 'package:freezed_annotation/freezed_annotation.dart';
import '../../library/data/models/track.dart';
import '../../zones/data/models/zone.dart';
import '../data/models/player_status.dart';

part 'now_playing_state.freezed.dart';

@freezed
sealed class NowPlayingState with _$NowPlayingState {
  const factory NowPlayingState.loading() = NowPlayingLoading;
  const factory NowPlayingState.data({
    required Zone zone,
    required PlayerStatus? status,
    required Track? track,
  }) = NowPlayingData;
}
