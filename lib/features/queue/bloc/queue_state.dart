import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/app_exception.dart';
import '../../library/data/models/tracks.dart';

part 'queue_state.freezed.dart';

@freezed
sealed class QueueState with _$QueueState {
  const factory QueueState.loading() = QueueLoading;
  const factory QueueState.loaded({
    required Tracks tracks,
    required int currentIndex,
  }) = QueueLoaded;
  const factory QueueState.error({required AppException error}) = QueueError;
}
