import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/tracks.dart';
import '../data/repositories/library_repository.dart';
import 'library_async_state.dart';

class FolderTracksCubit extends Cubit<LibAsync<Tracks>> {
  final LibraryRepository _repo;
  final String folderPath;

  FolderTracksCubit({
    required this.folderPath,
    required LibraryRepository repository,
  }) : _repo = repository,
       super(const LibAsync.loading()) {
    load();
  }

  Future<void> load() async {
    emit(const LibAsync.loading());
    final result = await _repo.getTracksByFolder(folderPath);
    result.fold(
      (e) => emit(LibAsync.error(error: e)),
      (tracks) => emit(LibAsync.data(value: tracks)),
    );
  }
}
