import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../library/data/models/track.dart';
import '../../library/data/models/tracks.dart';
import '../../player/player_command_service.dart';
import '../data/models/downloaded_track.dart';
import '../data/repositories/downloads_repository.dart';
import '../downloaded_tracks_service.dart';

typedef DownloadedArtistsState =
    List<({String artist, List<DownloadedTrack> tracks})>;

/// Companion of [DownloadedArtistsScreen]. Aggregates downloaded tracks
/// into a sorted list of artists. Provides action methods for bulk
/// playback and deletion.
class DownloadedArtistsCubit extends Cubit<DownloadedArtistsState> {
  final DownloadedTracksService _service;
  final DownloadsRepository _repo;
  final PlayerCommandService _commands;
  StreamSubscription<List<DownloadedTrack>>? _sub;

  DownloadedArtistsCubit({
    required DownloadedTracksService service,
    required DownloadsRepository repo,
    required PlayerCommandService commands,
  }) : _service = service,
       _repo = repo,
       _commands = commands,
       super(_compute(service.state)) {
    _sub = _service.stream.listen((s) {
      final next = _compute(s);
      if (!_stateEquals(next, state)) emit(next);
    });
  }

  static DownloadedArtistsState _compute(List<DownloadedTrack> all) {
    final Map<String, List<DownloadedTrack>> groups = {};
    for (final t in all) {
      final artist = t.albumArtist.isEmpty ? 'Unknown Artist' : t.albumArtist;
      groups.putIfAbsent(artist, () => []).add(t);
    }

    final sortedArtists = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return sortedArtists
        .map((artist) => (artist: artist, tracks: groups[artist]!))
        .toList();
  }

  static bool _stateEquals(DownloadedArtistsState a, DownloadedArtistsState b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].artist != b[i].artist) return false;
      if (a[i].tracks.length != b[i].tracks.length) return false;
      // Shallow track count/artist check is enough to trigger a rebuild
    }
    return true;
  }

  // Actions

  Future<void> play(List<DownloadedTrack> tracks) async {
    await _commands.playNow(Tracks(tracks: _sort(tracks)));
  }

  Future<void> playNext(List<DownloadedTrack> tracks) async {
    await _commands.playNext(Tracks(tracks: _sort(tracks)));
  }

  Future<void> add(List<DownloadedTrack> tracks) async {
    await _commands.addToQueue(Tracks(tracks: _sort(tracks)));
  }

  Future<void> delete(List<DownloadedTrack> tracks) async {
    await _repo.deleteAll(tracks.map((t) => t.fileKey).toList());
  }

  List<Track> _sort(List<DownloadedTrack> tracks) {
    return tracks.map((t) => t.track).toList()..sort((a, b) {
      final albumCompare = a.album.compareTo(b.album);
      if (albumCompare != 0) return albumCompare;
      final discCompare = a.discNumber.compareTo(b.discNumber);
      if (discCompare != 0) return discCompare;
      return a.trackNumber.compareTo(b.trackNumber);
    });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
