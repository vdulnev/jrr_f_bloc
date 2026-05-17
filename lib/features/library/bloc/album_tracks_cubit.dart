import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/album.dart';
import '../data/models/tracks.dart';
import '../data/repositories/library_repository.dart';
import 'library_async_state.dart';

class AlbumTracksCubit extends Cubit<LibAsync<Tracks>> {
  final LibraryRepository _repo;
  final Album album;

  AlbumTracksCubit({required this.album, required LibraryRepository repository})
    : _repo = repository,
      super(const LibAsync.loading()) {
    load();
  }

  Future<void> load() async {
    emit(const LibAsync.loading());
    final result = await _repo.getAlbumTracks(album);
    result.fold(
      (e) => emit(LibAsync.error(error: e)),
      (tracks) => emit(LibAsync.data(value: tracks)),
    );
  }
}
