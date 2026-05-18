import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_state.freezed.dart';

@freezed
abstract class LibraryState with _$LibraryState {
  const factory LibraryState({
    required bool isOffline,
    required int activeTabIndex,
  }) = _LibraryState;
}
