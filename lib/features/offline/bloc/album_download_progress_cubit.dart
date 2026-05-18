import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/download_job.dart';
import '../data/models/download_state.dart';
import '../download_jobs_service.dart';
import 'download_status.dart';

typedef AlbumDownloadProgressViewState =
    ({DownloadState status, double progress});

/// Companion of [AlbumDownloadProgressIndicator]. Emits the resolved
/// status + progress for an entire album-group.
class AlbumDownloadProgressCubit
    extends Cubit<AlbumDownloadProgressViewState> {
  final DownloadJobsService _jobs;
  final String albumGroupId;
  StreamSubscription<List<DownloadJob>>? _sub;

  AlbumDownloadProgressCubit({
    required this.albumGroupId,
    required DownloadJobsService jobs,
  }) : _jobs = jobs,
       super(_compute(albumGroupId, jobs.state)) {
    _sub = _jobs.stream.listen((_) {
      final next = _compute(albumGroupId, _jobs.state);
      if (next != state) emit(next);
    });
  }

  static AlbumDownloadProgressViewState _compute(
    String albumGroupId,
    List<DownloadJob> jobs,
  ) => (
    status: DownloadStatus.forAlbum(albumGroupId: albumGroupId, jobs: jobs),
    progress: DownloadStatus.progressForAlbum(
      albumGroupId: albumGroupId,
      jobs: jobs,
    ),
  );

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
