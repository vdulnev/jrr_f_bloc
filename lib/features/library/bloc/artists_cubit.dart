import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/library_repository.dart';
import 'library_async_state.dart';

class ArtistsCubit extends Cubit<LibAsync<List<String>>> {
  final LibraryRepository _repo;

  ArtistsCubit({required LibraryRepository repository})
    : _repo = repository,
      super(const LibAsync.loading()) {
    load();
  }

  Future<void> load() async {
    emit(const LibAsync.loading());
    final result = await _repo.getArtists();
    result.fold(
      (e) => emit(LibAsync.error(error: e)),
      (artists) => emit(LibAsync.data(value: artists)),
    );
  }
}
