import 'package:freezed_annotation/freezed_annotation.dart';

import '../../library/data/models/album.dart';

part 'downloaded_albums_state.freezed.dart';

@freezed
abstract class DownloadedAlbumsState with _$DownloadedAlbumsState {
  const factory DownloadedAlbumsState({
    @Default(<Album>[]) List<Album> albums,
  }) = _DownloadedAlbumsState;
}
