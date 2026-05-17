import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { nowPlaying, queue, library, zones, settings }

/// Holds the currently-selected top-level tab so the value survives any
/// reshuffling of the shell's widget tree (auto_route rebuilds, lifecycle
/// transitions, etc.) and stays observable from elsewhere in the bloc tree.
class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.nowPlaying);

  void select(AppTab tab) {
    if (state != tab) emit(tab);
  }
}
