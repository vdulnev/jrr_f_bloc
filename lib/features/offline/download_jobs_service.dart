import 'dart:async';

import 'data/models/download_job.dart';
import 'data/repositories/downloads_repository.dart';

/// Pure pipe off [DownloadsRepository.watchJobs]. Lives in the service
/// container so widgets observe job state through their companion
/// cubits instead of touching the repository directly.
class DownloadJobsService {
  final StreamController<List<DownloadJob>> _controller =
      StreamController<List<DownloadJob>>.broadcast();
  List<DownloadJob> _state = const [];
  StreamSubscription<List<DownloadJob>>? _sub;

  DownloadJobsService({required DownloadsRepository repository}) {
    _sub = repository.watchJobs().listen(_emit);
  }

  List<DownloadJob> get state => _state;
  Stream<List<DownloadJob>> get stream => _controller.stream;

  void _emit(List<DownloadJob> next) {
    _state = next;
    _controller.add(next);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
