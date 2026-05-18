import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../zones/active_zone_service.dart';
import 'library_state.dart';

/// Companion of [LibraryScreen]. Manages the active tab and the
/// offline-mode toggle (which restricts tabs to only "Downloads").
class LibraryCubit extends Cubit<LibraryState> {
  final ActiveZoneService _activeZone;
  StreamSubscription<dynamic>? _sub;

  LibraryCubit({required ActiveZoneService activeZone})
    : _activeZone = activeZone,
      super(
        LibraryState(
          isOffline: activeZone.state?.isOffline ?? false,
          activeTabIndex: 0,
        ),
      ) {
    _sub = _activeZone.stream.listen((z) {
      final isOffline = z?.isOffline ?? false;
      if (isOffline != state.isOffline) {
        emit(
          state.copyWith(
            isOffline: isOffline,
            activeTabIndex: isOffline ? 0 : state.activeTabIndex,
          ),
        );
      }
    });
  }

  void setActiveTab(int index) {
    if (index != state.activeTabIndex) {
      emit(state.copyWith(activeTabIndex: index));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
