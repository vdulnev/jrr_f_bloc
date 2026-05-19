import 'package:freezed_annotation/freezed_annotation.dart';

import '../../library/data/models/tracks.dart';

part 'downloaded_album_detail_state.freezed.dart';

@freezed
abstract class DownloadedAlbumDetailState with _$DownloadedAlbumDetailState {
  const factory DownloadedAlbumDetailState({
    @Default(Tracks.empty) Tracks tracks,
  }) = _DownloadedAlbumDetailState;
}
