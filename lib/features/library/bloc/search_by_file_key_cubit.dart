import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/track.dart';
import '../data/repositories/library_repository.dart';

/// Enriches a Now Playing entry with full metadata (File/GetInfo).
/// Used by the now-playing screen header for date/file-type/etc.
class SearchByFileKeyCubit extends Cubit<Track?> {
  final LibraryRepository _repo;

  SearchByFileKeyCubit({required LibraryRepository repository})
    : _repo = repository,
      super(null);

  Future<void> lookup(int fileKey) async {
    if (fileKey <= 0) {
      emit(null);
      return;
    }
    final result = await _repo.searchByFileKey(fileKey);
    result.fold((_) => emit(null), emit);
  }
}
