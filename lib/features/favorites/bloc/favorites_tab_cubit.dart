import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../library/data/models/browse_item.dart';
import '../favorites_service.dart';
import 'favorites_tab_state.dart';

/// Companion of [FavoritesTab]. State is just the favorite list — the
/// breadcrumb stack inside the tab still belongs to [BrowseNavigationCubit].
class FavoritesTabCubit extends Cubit<FavoritesTabState> {
  final FavoritesService _service;
  StreamSubscription<List<BrowseItem>>? _sub;

  FavoritesTabCubit({required FavoritesService service})
    : _service = service,
      super(FavoritesTabState(items: service.state)) {
    _sub = _service.stream.listen(
      (items) => emit(FavoritesTabState(items: items)),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
