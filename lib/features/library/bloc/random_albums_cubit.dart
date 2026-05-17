import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/albums.dart';
import '../data/repositories/library_repository.dart';
import 'library_async_state.dart';

class RandomAlbumsCubit extends Cubit<LibAsync<Albums>> {
  final LibraryRepository _repo;

  RandomAlbumsCubit({required LibraryRepository repository})
    : _repo = repository,
      super(const LibAsync.loading()) {
    load();
  }

  Future<void> load() async {
    emit(const LibAsync.loading());
    final result = await _repo.getRandomAlbums();
    result.fold(
      (e) => emit(LibAsync.error(error: e)),
      (albums) => emit(LibAsync.data(value: albums)),
    );
  }
}
