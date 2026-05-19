import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../library/data/models/tracks.dart';
import '../data/models/downloaded_track.dart';
import '../downloaded_tracks_service.dart';
import 'downloaded_album_detail_state.dart';

/// Companion of [DownloadedAlbumDetailScreen]. Filters and sorts
/// downloaded tracks for a specific albumGroupId.
class DownloadedAlbumDetailCubit extends Cubit<DownloadedAlbumDetailState> {
  final String albumGroupId;
  final DownloadedTracksService _service;
  StreamSubscription<List<DownloadedTrack>>? _sub;

  DownloadedAlbumDetailCubit({
    required this.albumGroupId,
    required DownloadedTracksService service,
  }) : _service = service,
       super(
         DownloadedAlbumDetailState(
           tracks: _compute(albumGroupId, service.state),
         ),
       ) {
    _sub = _service.stream.listen((s) {
      final next = _compute(albumGroupId, s);
      if (!_tracksEquals(next, state.tracks)) {
        emit(DownloadedAlbumDetailState(tracks: next));
      }
    });
  }

  static Tracks _compute(String albumGroupId, List<DownloadedTrack> all) {
    final filtered =
        all
            .where((t) => t.albumGroupId == albumGroupId)
            .map((t) => t.track)
            .toList()
          ..sort((a, b) {
            final discCompare = a.discNumber.compareTo(b.discNumber);
            if (discCompare != 0) return discCompare;
            return a.trackNumber.compareTo(b.trackNumber);
          });
    return Tracks(tracks: filtered);
  }

  static bool _tracksEquals(Tracks a, Tracks b) {
    if (identical(a, b)) return true;
    if (a.tracks.length != b.tracks.length) return false;
    for (var i = 0; i < a.tracks.length; i++) {
      if (a.tracks[i].fileKey != b.tracks[i].fileKey) return false;
    }
    return true;
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
