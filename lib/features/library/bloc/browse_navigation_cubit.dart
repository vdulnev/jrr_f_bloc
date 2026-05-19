import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/browse_item.dart';
import 'browse_navigation_state.dart';

enum BrowseScope { browse, favorites }

/// Drives the breadcrumb stack for a [BrowseScope]. Push when entering a
/// child level, pop on back, navigateToBreadcrumb when the user taps a
/// crumb directly.
class BrowseNavigationCubit extends Cubit<BrowseNavigationState> {
  final BrowseScope scope;

  BrowseNavigationCubit({required this.scope})
    : super(BrowseNavigationState(stack: _initial(scope)));

  static List<BrowseItem> _initial(BrowseScope scope) => switch (scope) {
    BrowseScope.browse => const [BrowseItem(id: '-1', name: 'Browse')],
    BrowseScope.favorites => const [],
  };

  void push(BrowseItem level) =>
      emit(BrowseNavigationState(stack: [...state.stack, level]));

  void pop() {
    if (state.stack.isNotEmpty) {
      emit(
        BrowseNavigationState(
          stack: state.stack.sublist(0, state.stack.length - 1),
        ),
      );
    }
  }

  void reset() => emit(const BrowseNavigationState());

  void navigateToBreadcrumb(int index) {
    if (index == -1) {
      emit(const BrowseNavigationState());
    } else if (index >= 0 && index < state.stack.length - 1) {
      emit(BrowseNavigationState(stack: state.stack.sublist(0, index + 1)));
    }
  }
}
