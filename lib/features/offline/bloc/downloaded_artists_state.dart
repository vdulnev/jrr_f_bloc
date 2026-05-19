import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/models/downloaded_track.dart';

part 'downloaded_artists_state.freezed.dart';

typedef ArtistGroup = ({String artist, List<DownloadedTrack> tracks});

@freezed
abstract class DownloadedArtistsState with _$DownloadedArtistsState {
  const factory DownloadedArtistsState({
    @Default(<ArtistGroup>[]) List<ArtistGroup> groups,
  }) = _DownloadedArtistsState;
}
