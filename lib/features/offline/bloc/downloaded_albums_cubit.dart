import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/extensions/string_extensions.dart';
import '../../library/data/models/album.dart';
import '../data/models/downloaded_track.dart';
import '../downloaded_tracks_service.dart';

typedef DownloadedAlbumsState = List<Album>;

/// Companion of [DownloadedAlbumsScreen]. Filters and sorts downloaded
/// albums for a specific artist.
class DownloadedAlbumsCubit extends Cubit<DownloadedAlbumsState> {
  final String artist;
  final DownloadedTracksService _service;
  StreamSubscription<List<DownloadedTrack>>? _sub;

  DownloadedAlbumsCubit({
    required this.artist,
    required DownloadedTracksService service,
  }) : _service = service,
       super(_compute(artist, service.state)) {
    _sub = _service.stream.listen((s) {
      final next = _compute(artist, s);
      if (!_listEquals(next, state)) emit(next);
    });
  }

  static DownloadedAlbumsState _compute(
    String artist,
    List<DownloadedTrack> all,
  ) {
    final groups = <String, Album>{};
    for (final t in all) {
      final tArtist = t.albumArtist.isEmpty ? 'Unknown Artist' : t.albumArtist;
      if (!tArtist.equalsIgnoreCase(artist)) continue;
      groups.putIfAbsent(t.albumGroupId, () => Album.fromTrack(t.track));
    }
    final albums = groups.values.toList()
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return a.name.compareTo(b.name);
      });
    return albums;
  }

  static bool _listEquals(List<Album> a, List<Album> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].albumGroupId != b[i].albumGroupId) return false;
    }
    return true;
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
