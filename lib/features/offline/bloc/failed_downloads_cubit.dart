import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/download_job.dart';
import '../data/models/download_state.dart';
import '../data/repositories/downloads_repository.dart';
import '../download_jobs_service.dart';

/// Companion of the server-manager FAILED DOWNLOADS section. State is
/// the filtered list of jobs whose `state == DownloadState.failed`.
class FailedDownloadsCubit extends Cubit<List<DownloadJob>> {
  final DownloadJobsService _jobs;
  final DownloadsRepository _repo;
  StreamSubscription<List<DownloadJob>>? _sub;

  FailedDownloadsCubit({
    required DownloadJobsService jobs,
    required DownloadsRepository repo,
  }) : _jobs = jobs,
       _repo = repo,
       super(_filter(jobs.state)) {
    _sub = _jobs.stream.listen((s) {
      final next = _filter(s);
      if (!_listEquals(next, state)) emit(next);
    });
  }

  static List<DownloadJob> _filter(List<DownloadJob> all) =>
      all.where((j) => j.state == DownloadState.failed).toList();

  static bool _listEquals(List<DownloadJob> a, List<DownloadJob> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].fileKey != b[i].fileKey) return false;
    }
    return true;
  }

  Future<void> retry(DownloadJob job) async {
    await _repo.enqueue(job.track);
  }

  Future<void> remove(DownloadJob job) async {
    await _repo.removeJob(job.fileKey);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
