import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stream_transform/stream_transform.dart';

import '../data/models/tracks.dart';
import '../data/repositories/library_repository.dart';
import 'library_async_state.dart';

part 'search_bloc.freezed.dart';

@freezed
sealed class SearchEvent with _$SearchEvent {
  const factory SearchEvent.queryChanged({required String query}) =
      SearchQueryChanged;
  const factory SearchEvent.cleared() = SearchCleared;
}

EventTransformer<E> _debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(events.debounce(duration), mapper);
}

/// Searches the library. Restartable + debounced — each new keystroke
/// cancels the in-flight request, so we never paint stale results.
class SearchBloc extends Bloc<SearchEvent, LibAsync<Tracks>> {
  final LibraryRepository _repo;

  SearchBloc({required LibraryRepository repository})
    : _repo = repository,
      super(const LibAsync.data(value: Tracks.empty)) {
    on<SearchQueryChanged>(
      _onQuery,
      transformer: _debounceRestartable(const Duration(milliseconds: 250)),
    );
    on<SearchCleared>(
      (event, emit) => emit(const LibAsync.data(value: Tracks.empty)),
    );
  }

  Future<void> _onQuery(
    SearchQueryChanged event,
    Emitter<LibAsync<Tracks>> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const LibAsync.data(value: Tracks.empty));
      return;
    }
    emit(const LibAsync.loading());
    final result = await _repo.search(query);
    if (emit.isDone) return;
    result.fold(
      (e) => emit(LibAsync.error(error: e)),
      (tracks) => emit(LibAsync.data(value: tracks)),
    );
  }
}
