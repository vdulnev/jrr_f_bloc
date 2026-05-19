import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/models/download_job.dart';

part 'failed_downloads_state.freezed.dart';

@freezed
abstract class FailedDownloadsState with _$FailedDownloadsState {
  const factory FailedDownloadsState({
    @Default(<DownloadJob>[]) List<DownloadJob> jobs,
  }) = _FailedDownloadsState;
}
