import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../library/data/models/browse_item.dart';
import '../favorites_service.dart';

/// Companion of [BrowseItemTile]. State is the boolean favorite status
/// for [item]; `toggle()` flips it via [FavoritesService].
class BrowseItemTileCubit extends Cubit<bool> {
  final FavoritesService _service;
  final BrowseItem item;
  StreamSubscription<List<BrowseItem>>? _sub;

  BrowseItemTileCubit({required this.item, required FavoritesService service})
    : _service = service,
      super(service.isFavorite(item)) {
    _sub = _service.stream.listen((favs) {
      final next = favs.any((f) => f.id == item.id);
      if (next != state) emit(next);
    });
  }

  Future<void> toggle() => _service.toggle(item);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
