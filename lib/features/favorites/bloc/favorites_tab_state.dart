import 'package:freezed_annotation/freezed_annotation.dart';

import '../../library/data/models/browse_item.dart';

part 'favorites_tab_state.freezed.dart';

@freezed
abstract class FavoritesTabState with _$FavoritesTabState {
  const factory FavoritesTabState({
    @Default(<BrowseItem>[]) List<BrowseItem> items,
  }) = _FavoritesTabState;
}
