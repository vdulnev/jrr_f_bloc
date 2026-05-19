import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/models/browse_item.dart';

part 'browse_navigation_state.freezed.dart';

@freezed
abstract class BrowseNavigationState with _$BrowseNavigationState {
  const factory BrowseNavigationState({
    @Default(<BrowseItem>[]) List<BrowseItem> stack,
  }) = _BrowseNavigationState;
}
