import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/browse_item.dart';
import '../data/repositories/library_repository.dart';
import 'library_async_state.dart';

class BrowseChildrenCubit extends Cubit<LibAsync<List<BrowseItem>>> {
  final LibraryRepository _repo;
  final String id;

  BrowseChildrenCubit({
    required this.id,
    required LibraryRepository repository,
  }) : _repo = repository,
       super(const LibAsync.loading()) {
    load();
  }

  Future<void> load() async {
    emit(const LibAsync.loading());
    final result = await _repo.browseChildren(id);
    result.fold(
      (e) => emit(LibAsync.error(error: e)),
      (items) => emit(LibAsync.data(value: items)),
    );
  }
}
