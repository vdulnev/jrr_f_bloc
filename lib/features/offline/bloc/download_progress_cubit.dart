import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/download_job.dart';
import '../data/models/download_state.dart';
import '../data/models/downloaded_track.dart';
import '../download_jobs_service.dart';
import '../downloaded_tracks_service.dart';
import 'download_status.dart';

typedef DownloadProgressViewState = ({DownloadState status, double progress});

/// Companion of [DownloadProgressIndicator]. Emits the resolved status
/// and progress for a single [fileKey], folding both download services.
class DownloadProgressCubit extends Cubit<DownloadProgressViewState> {
  final DownloadedTracksService _tracks;
  final DownloadJobsService _jobs;
  final int fileKey;

  StreamSubscription<List<DownloadedTrack>>? _dlSub;
  StreamSubscription<List<DownloadJob>>? _jobSub;

  DownloadProgressCubit({
    required this.fileKey,
    required DownloadedTracksService tracks,
    required DownloadJobsService jobs,
  }) : _tracks = tracks,
       _jobs = jobs,
       super(_compute(fileKey, tracks.state, jobs.state)) {
    _dlSub = _tracks.stream.listen((_) => _recompute());
    _jobSub = _jobs.stream.listen((_) => _recompute());
  }

  void _recompute() {
    final next = _compute(fileKey, _tracks.state, _jobs.state);
    if (next != state) emit(next);
  }

  static DownloadProgressViewState _compute(
    int fileKey,
    List<DownloadedTrack> downloaded,
    List<DownloadJob> jobs,
  ) => (
    status: DownloadStatus.forTrack(
      fileKey: fileKey,
      downloaded: downloaded,
      jobs: jobs,
    ),
    progress: DownloadStatus.progressForTrack(fileKey: fileKey, jobs: jobs),
  );

  @override
  Future<void> close() async {
    await _dlSub?.cancel();
    await _jobSub?.cancel();
    return super.close();
  }
}
