import 'dart:async';

import '../library/data/models/browse_item.dart';
import 'data/repositories/favorites_repository.dart';

/// Owns the set of favorited browse-tree nodes. Lives in the service
/// container; widgets observe it through their companion cubits.
class FavoritesService {
  final FavoritesRepository _repo;

  final StreamController<List<BrowseItem>> _controller =
      StreamController<List<BrowseItem>>.broadcast();
  List<BrowseItem> _state = const [];

  FavoritesService({required FavoritesRepository repository})
    : _repo = repository {
    scheduleMicrotask(reload);
  }

  List<BrowseItem> get state => _state;
  Stream<List<BrowseItem>> get stream => _controller.stream;

  void _emit(List<BrowseItem> next) {
    if (_listEquals(_state, next)) return;
    _state = next;
    _controller.add(next);
  }

  static bool _listEquals(List<BrowseItem> a, List<BrowseItem> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  bool isFavorite(BrowseItem item) => _state.any((f) => f.id == item.id);

  Future<void> reload() async {
    final result = await _repo.getAll();
    result.fold(
      (_) => _emit(const []),
      (favs) => _emit(
        favs
            .map((f) => BrowseItem(id: f.identifier, name: f.displayName))
            .toList(),
      ),
    );
  }

  Future<void> toggle(BrowseItem item) async {
    if (isFavorite(item)) {
      await _repo.removeFavorite(item);
    } else {
      await _repo.addFavorite(item);
    }
    await reload();
  }

  Future<void> dispose() async => _controller.close();
}
