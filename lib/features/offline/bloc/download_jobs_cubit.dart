import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/download_job.dart';
import '../data/repositories/downloads_repository.dart';

/// Streams the in-flight download jobs from [DownloadsRepository].
class DownloadJobsCubit extends Cubit<List<DownloadJob>> {
  StreamSubscription<List<DownloadJob>>? _sub;

  DownloadJobsCubit({required DownloadsRepository repository})
    : super(const []) {
    _sub = repository.watchJobs().listen(emit);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
