import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../offline/bloc/download_status.dart';
import '../../offline/data/models/download_job.dart';
import '../../offline/data/models/download_state.dart';
import '../../offline/data/models/downloaded_track.dart';
import '../../offline/data/repositories/downloads_repository.dart';
import '../../offline/download_jobs_service.dart';
import '../../offline/downloaded_tracks_service.dart';
import '../../player/player_command_service.dart';
import '../../zones/active_zone_service.dart';
import '../../zones/data/models/zone.dart';
import '../data/models/track.dart';
import '../data/models/tracks.dart';

typedef LibraryItemTileViewState = ({bool isOffline, DownloadState status});

/// Companion of [LibraryItemTile]. Aggregates the active zone + the
/// per-track download status into one record. Provides action methods
/// that delegate to the appropriate controller/repository.
class LibraryItemTileCubit extends Cubit<LibraryItemTileViewState> {
  final Track _track;
  final ActiveZoneService _activeZone;
  final DownloadedTracksService _tracks;
  final DownloadJobsService _jobs;
  final DownloadsRepository _repo;
  final PlayerCommandService _commands;

  StreamSubscription<Zone?>? _zoneSub;
  StreamSubscription<List<DownloadedTrack>>? _dlSub;
  StreamSubscription<List<DownloadJob>>? _jobSub;

  LibraryItemTileCubit({
    required Track track,
    required ActiveZoneService activeZone,
    required DownloadedTracksService tracks,
    required DownloadJobsService jobs,
    required DownloadsRepository repo,
    required PlayerCommandService commands,
  }) : _track = track,
       _activeZone = activeZone,
       _tracks = tracks,
       _jobs = jobs,
       _repo = repo,
       _commands = commands,
       super(
         _compute(track.fileKey, activeZone.state, tracks.state, jobs.state),
       ) {
    _zoneSub = _activeZone.stream.listen((_) => _recompute());
    _dlSub = _tracks.stream.listen((_) => _recompute());
    _jobSub = _jobs.stream.listen((_) => _recompute());
  }

  void _recompute() {
    final next = _compute(
      _track.fileKey,
      _activeZone.state,
      _tracks.state,
      _jobs.state,
    );
    if (next != state) emit(next);
  }

  static LibraryItemTileViewState _compute(
    int fileKey,
    Zone? activeZone,
    List<DownloadedTrack> downloaded,
    List<DownloadJob> jobs,
  ) => (
    isOffline: activeZone?.isOffline == true,
    status: DownloadStatus.forTrack(
      fileKey: fileKey,
      downloaded: downloaded,
      jobs: jobs,
    ),
  );

  // Actions

  Future<void> play() async {
    await _commands.playNow(Tracks(tracks: [_track]));
  }

  Future<void> playNext() async {
    await _commands.playNext(Tracks(tracks: [_track]));
  }

  Future<void> add() async {
    await _commands.addToQueue(Tracks(tracks: [_track]));
  }

  Future<void> download() async {
    await _repo.enqueue(_track);
  }

  Future<void> cancelDownload() async {
    await _repo.cancel(_track.fileKey);
  }

  Future<void> deleteDownload() async {
    await _repo.delete(_track.fileKey);
  }

  @override
  Future<void> close() async {
    await _zoneSub?.cancel();
    await _dlSub?.cancel();
    await _jobSub?.cancel();
    return super.close();
  }
}
