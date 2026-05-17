import 'package:flutter_bloc/flutter_bloc.dart';

import '../../library/data/models/browse_item.dart';
import '../data/repositories/favorites_repository.dart';

/// Holds the set of favorited browse-tree nodes.
class FavoritesCubit extends Cubit<List<BrowseItem>> {
  final FavoritesRepository _repo;

  FavoritesCubit({required FavoritesRepository repository})
    : _repo = repository,
      super(const []) {
    load();
  }

  Future<void> load() async {
    final result = await _repo.getAll();
    result.fold(
      (_) => emit(const []),
      (favs) => emit(
        favs
            .map((f) => BrowseItem(id: f.identifier, name: f.displayName))
            .toList(),
      ),
    );
  }

  bool isFavorite(BrowseItem item) => state.any((f) => f.id == item.id);

  Future<void> toggle(BrowseItem item) async {
    if (isFavorite(item)) {
      await _repo.removeFavorite(item);
    } else {
      await _repo.addFavorite(item);
    }
    await load();
  }
}
