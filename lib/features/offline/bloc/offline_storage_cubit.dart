import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/downloaded_track.dart';
import '../data/repositories/downloads_repository.dart';
import '../downloaded_tracks_service.dart';

typedef OfflineStorageViewState = ({int count, int totalBytes});

/// Companion of the server-manager OFFLINE STORAGE section. State is the
/// count + total byte size of everything in the [DownloadedTracksService].
class OfflineStorageCubit extends Cubit<OfflineStorageViewState> {
  final DownloadedTracksService _tracks;
  final DownloadsRepository _repo;
  StreamSubscription<List<DownloadedTrack>>? _sub;

  OfflineStorageCubit({
    required DownloadedTracksService tracks,
    required DownloadsRepository repo,
  }) : _tracks = tracks,
       _repo = repo,
       super(_compute(tracks.state)) {
    _sub = _tracks.stream.listen((s) {
      final next = _compute(s);
      if (next != state) emit(next);
    });
  }

  static OfflineStorageViewState _compute(List<DownloadedTrack> tracks) {
    final count = tracks.length;
    final totalBytes = tracks.fold<int>(0, (sum, t) => sum + t.fileSizeBytes);
    return (count: count, totalBytes: totalBytes);
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
