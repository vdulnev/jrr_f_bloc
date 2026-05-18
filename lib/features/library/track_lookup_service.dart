import 'dart:async';

import 'data/models/track.dart';
import 'data/repositories/library_repository.dart';

/// Resolves a single track by file key via `File/GetInfo`. Used to enrich
/// a Now Playing entry's metadata (date, file type, etc.) on top of the
/// thin `Playback/Info` payload.
///
/// Lives in the service container so widgets observe it through their
/// companion cubits instead of touching `LibraryRepository` directly.
class TrackLookupService {
  final LibraryRepository _repo;

  final StreamController<Track?> _controller =
      StreamController<Track?>.broadcast();
  Track? _state;
  int _lastFileKey = -1;

  TrackLookupService({required LibraryRepository repository})
    : _repo = repository;

  Track? get state => _state;
  Stream<Track?> get stream => _controller.stream;

  void _emit(Track? next) {
    if (_state == next) return;
    _state = next;
    _controller.add(next);
  }

  /// Fetches the track for [fileKey]. A non-positive key clears the
  /// state. Same-key calls are de-duped — useful when the now-playing
  /// snapshot re-emits with an unchanged track.
  Future<void> lookup(int fileKey) async {
    if (fileKey <= 0) {
      _lastFileKey = -1;
      _emit(null);
      return;
    }
    if (fileKey == _lastFileKey) return;
    _lastFileKey = fileKey;
    final result = await _repo.searchByFileKey(fileKey);
    if (_lastFileKey != fileKey) return; // Superseded by a newer lookup.
    result.fold((_) => _emit(null), _emit);
  }

  Future<void> dispose() async => _controller.close();
}
