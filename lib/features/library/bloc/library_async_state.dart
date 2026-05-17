import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/app_exception.dart';

part 'library_async_state.freezed.dart';

/// Shared async state used by every library cubit so widgets switch on a
/// single shape regardless of which list they're loading.
@freezed
sealed class LibAsync<T> with _$LibAsync<T> {
  const factory LibAsync.loading() = LibLoading<T>;
  const factory LibAsync.data({required T value}) = LibData<T>;
  const factory LibAsync.error({required AppException error}) = LibError<T>;
}
