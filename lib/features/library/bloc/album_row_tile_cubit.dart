import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../offline/data/models/download_job.dart';
import '../../offline/data/models/download_state.dart';
import '../../offline/data/models/downloaded_track.dart';
import '../../offline/data/repositories/downloads_repository.dart';
import '../../offline/download_jobs_service.dart';
import '../../offline/downloaded_tracks_service.dart';
import '../../player/player_command_service.dart';
import '../../zones/active_zone_service.dart';
import '../../zones/data/models/zone.dart';
import '../data/models/album.dart';
import '../data/models/tracks.dart';
import '../data/repositories/library_repository.dart';

/// All the booleans / fragments [AlbumRowTile] needs to render. Hidden is
/// `true` when offline-mode + nothing-downloaded; the tile collapses to
/// `SizedBox.shrink()` in that case.
typedef AlbumRowTileViewState = ({
  bool hidden,
  bool isOffline,
  bool showDownload,
  bool showCancel,
  bool showDelete,
  bool showRetry,
});

class AlbumRowTileCubit extends Cubit<AlbumRowTileViewState> {
  final Album _album;
  final ActiveZoneService _activeZone;
  final DownloadedTracksService _tracks;
  final DownloadJobsService _jobs;
  final LibraryRepository _library;
  final DownloadsRepository _repo;
  final PlayerCommandService _commands;

  StreamSubscription<Zone?>? _zoneSub;
  StreamSubscription<List<DownloadedTrack>>? _dlSub;
  StreamSubscription<List<DownloadJob>>? _jobSub;

  AlbumRowTileCubit({
    required Album album,
    required ActiveZoneService activeZone,
    required DownloadedTracksService tracks,
    required DownloadJobsService jobs,
    required LibraryRepository library,
    required DownloadsRepository repo,
    required PlayerCommandService commands,
  }) : _album = album,
       _activeZone = activeZone,
       _tracks = tracks,
       _jobs = jobs,
       _library = library,
       _repo = repo,
       _commands = commands,
       super(
         _compute(
           album.albumGroupId,
           activeZone.state,
           tracks.state,
           jobs.state,
         ),
       ) {
    _zoneSub = _activeZone.stream.listen((_) => _recompute());
    _dlSub = _tracks.stream.listen((_) => _recompute());
    _jobSub = _jobs.stream.listen((_) => _recompute());
  }

  void _recompute() {
    final next = _compute(
      _album.albumGroupId,
      _activeZone.state,
      _tracks.state,
      _jobs.state,
    );
    if (next != state) emit(next);
  }

  static AlbumRowTileViewState _compute(
    String albumGroupId,
    Zone? activeZone,
    List<DownloadedTrack> downloaded,
    List<DownloadJob> jobs,
  ) {
    final isOffline = activeZone?.isOffline == true;
    final downloadedInAlbum = downloaded
        .where((t) => t.albumGroupId == albumGroupId)
        .toList();
    final hidden = isOffline && downloadedInAlbum.isEmpty;
    final jobsInAlbum = jobs
        .where((j) => j.track.albumGroupId == albumGroupId)
        .toList();
    final activeJobs = jobsInAlbum.where(
      (j) =>
          j.state == DownloadState.queued || j.state == DownloadState.running,
    );
    final failedJobs = jobsInAlbum.where(
      (j) => j.state == DownloadState.failed,
    );
    return (
      hidden: hidden,
      isOffline: isOffline,
      showDownload: !isOffline && activeJobs.isEmpty,
      showCancel: !isOffline && activeJobs.isNotEmpty,
      showDelete: downloadedInAlbum.isNotEmpty,
      showRetry: !isOffline && failedJobs.isNotEmpty && activeJobs.isEmpty,
    );
  }

  // Actions

  Future<void> play() async {
    final tracks = await _resolveTracks();
    if (tracks != null) {
      await _commands.playNow(tracks);
      await _commands.refresh();
    }
  }

  Future<void> playNext() async {
    final tracks = await _resolveTracks();
    if (tracks != null) {
      await _commands.playNext(tracks);
      await _commands.refresh();
    }
  }

  Future<void> add() async {
    final tracks = await _resolveTracks();
    if (tracks != null) {
      await _commands.addToQueue(tracks);
      await _commands.refresh();
    }
  }

  Future<void> download() async {
    final tracks = await _resolveTracks();
    if (tracks != null) {
      await _repo.enqueueAll(tracks.tracks);
    }
  }

  Future<void> cancelDownload() async {
    final tracks = await _resolveTracks();
    if (tracks != null) {
      await _repo.cancelAll(tracks.tracks.map((t) => t.fileKey).toList());
    }
  }

  Future<void> deleteDownload() async {
    final tracks = await _resolveTracks();
    if (tracks != null) {
      await _repo.deleteAll(tracks.tracks.map((t) => t.fileKey).toList());
    }
  }

  Future<Tracks?> _resolveTracks() async {
    if (state.isOffline) {
      final filtered =
          _tracks.state
              .where((t) => t.albumGroupId == _album.albumGroupId)
              .map((t) => t.track)
              .toList()
            ..sort((a, b) {
              final discCompare = a.discNumber.compareTo(b.discNumber);
              if (discCompare != 0) return discCompare;
              return a.trackNumber.compareTo(b.trackNumber);
            });
      return Tracks(tracks: filtered);
    }
    return (await _library.getAlbumTracks(_album)).match((_) => null, (t) => t);
  }

  @override
  Future<void> close() async {
    await _zoneSub?.cancel();
    await _dlSub?.cancel();
    await _jobSub?.cancel();
    return super.close();
  }
}
