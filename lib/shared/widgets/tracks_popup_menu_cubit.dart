import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/library/data/models/track.dart';
import '../../features/library/data/models/tracks.dart';
import '../../features/offline/data/models/download_job.dart';
import '../../features/offline/data/models/download_state.dart';
import '../../features/offline/data/models/downloaded_track.dart';
import '../../features/offline/data/repositories/downloads_repository.dart';
import '../../features/offline/download_jobs_service.dart';
import '../../features/offline/downloaded_tracks_service.dart';
import '../../features/player/bloc/player_controller_cubit.dart';
import '../../features/zones/active_zone_service.dart';
import '../../features/zones/data/models/zone.dart';

typedef TracksPopupMenuViewState =
    ({
      bool hidden,
      bool showDownload,
      bool showCancel,
      bool showDelete,
      bool showRetry,
    });

/// Companion of [TracksPopupMenu]. Emits exactly the boolean fragments
/// the popup needs given the menu's track set + the live download state.
/// Provides action methods that delegate to the appropriate controller/
/// repository.
class TracksPopupMenuCubit extends Cubit<TracksPopupMenuViewState> {
  final List<Track> _tracksList;
  final Set<int> _trackKeys;
  final int _totalTracks;
  final ActiveZoneService _activeZone;
  final DownloadedTracksService _tracks;
  final DownloadJobsService _jobs;
  final DownloadsRepository _repo;

  StreamSubscription<Zone?>? _zoneSub;
  StreamSubscription<List<DownloadedTrack>>? _dlSub;
  StreamSubscription<List<DownloadJob>>? _jobSub;

  TracksPopupMenuCubit({
    required Iterable<Track> tracks,
    required ActiveZoneService activeZone,
    required DownloadedTracksService tracksService,
    required DownloadJobsService jobs,
    required DownloadsRepository repo,
  }) : _tracksList = tracks.toList(),
       _trackKeys = tracks.map((t) => t.fileKey).toSet(),
       _totalTracks = tracks.length,
       _activeZone = activeZone,
       _tracks = tracksService,
       _jobs = jobs,
       _repo = repo,
       super(
         _compute(
           tracks.map((t) => t.fileKey).toSet(),
           tracks.length,
           activeZone.state,
           tracksService.state,
           jobs.state,
         ),
       ) {
    _zoneSub = _activeZone.stream.listen((_) => _recompute());
    _dlSub = _tracks.stream.listen((_) => _recompute());
    _jobSub = _jobs.stream.listen((_) => _recompute());
  }

  void _recompute() {
    final next = _compute(
      _trackKeys,
      _totalTracks,
      _activeZone.state,
      _tracks.state,
      _jobs.state,
    );
    if (next != state) emit(next);
  }

  static TracksPopupMenuViewState _compute(
    Set<int> trackKeys,
    int total,
    Zone? activeZone,
    List<DownloadedTrack> downloaded,
    List<DownloadJob> jobs,
  ) {
    final isOffline = activeZone?.isOffline == true;
    final downloadedKeys = downloaded
        .where((t) => trackKeys.contains(t.fileKey))
        .map((t) => t.fileKey)
        .toSet();
    if (isOffline && downloadedKeys.isEmpty) {
      return (
        hidden: true,
        showDownload: false,
        showCancel: false,
        showDelete: false,
        showRetry: false,
      );
    }
    final jobsForTracks =
        jobs.where((j) => trackKeys.contains(j.fileKey)).toList();
    final activeJobs = jobsForTracks.where(
      (j) =>
          j.state == DownloadState.queued || j.state == DownloadState.running,
    );
    final failedJobs = jobsForTracks.where(
      (j) => j.state == DownloadState.failed,
    );
    return (
      hidden: false,
      showDownload:
          !isOffline && downloadedKeys.length < total && activeJobs.isEmpty,
      showCancel: !isOffline && activeJobs.isNotEmpty,
      showDelete: downloadedKeys.isNotEmpty,
      showRetry: !isOffline && failedJobs.isNotEmpty && activeJobs.isEmpty,
    );
  }

  // Actions

  Future<void> play(PlayerControllerCubit controller) async {
    await controller.playNow(Tracks(tracks: _tracksList));
    await controller.refresh();
  }

  Future<void> playNext(PlayerControllerCubit controller) async {
    await controller.playNext(Tracks(tracks: _tracksList));
    await controller.refresh();
  }

  Future<void> add(PlayerControllerCubit controller) async {
    await controller.addToQueue(Tracks(tracks: _tracksList));
    await controller.refresh();
  }

  Future<void> download() async {
    await _repo.enqueueAll(_tracksList);
  }

  Future<void> cancelDownload() async {
    await _repo.cancelAll(_trackKeys.toList());
  }

  Future<void> deleteDownload() async {
    await _repo.deleteAll(_trackKeys.toList());
  }

  @override
  Future<void> close() async {
    await _zoneSub?.cancel();
    await _dlSub?.cancel();
    await _jobSub?.cancel();
    return super.close();
  }
}
