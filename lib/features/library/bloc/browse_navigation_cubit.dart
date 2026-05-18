import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/browse_item.dart';

enum BrowseScope { browse, favorites }

/// Drives the breadcrumb stack for a [BrowseScope]. Push when entering a
/// child level, pop on back, navigateToBreadcrumb when the user taps a
/// crumb directly.
class BrowseNavigationCubit extends Cubit<List<BrowseItem>> {
  final BrowseScope scope;

  BrowseNavigationCubit({required this.scope}) : super(_initial(scope));

  static List<BrowseItem> _initial(BrowseScope scope) => switch (scope) {
    BrowseScope.browse => const [BrowseItem(id: '-1', name: 'Browse')],
    BrowseScope.favorites => const [],
  };

  void push(BrowseItem level) => emit([...state, level]);

  void pop() {
    if (state.isNotEmpty) emit(state.sublist(0, state.length - 1));
  }

  void reset() => emit(const []);

  void navigateToBreadcrumb(int index) {
    if (index == -1) {
      emit(const []);
    } else if (index >= 0 && index < state.length - 1) {
      emit(state.sublist(0, index + 1));
    }
  }
}
