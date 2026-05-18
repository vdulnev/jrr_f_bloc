import 'dart:async';

import 'data/models/downloaded_track.dart';
import 'data/repositories/downloads_repository.dart';

/// Pure pipe off [DownloadsRepository.watchDownloadedTracks]. Lives in
/// the service container so widgets observe the on-disk cache through
/// their companion cubits instead of touching the repository directly.
class DownloadedTracksService {
  final StreamController<List<DownloadedTrack>> _controller =
      StreamController<List<DownloadedTrack>>.broadcast();
  List<DownloadedTrack> _state = const [];
  StreamSubscription<List<DownloadedTrack>>? _sub;

  DownloadedTracksService({required DownloadsRepository repository}) {
    _sub = repository.watchDownloadedTracks().listen(_emit);
  }

  List<DownloadedTrack> get state => _state;
  Stream<List<DownloadedTrack>> get stream => _controller.stream;

  void _emit(List<DownloadedTrack> next) {
    _state = next;
    _controller.add(next);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
