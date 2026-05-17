import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/downloaded_track.dart';
import '../data/repositories/downloads_repository.dart';

/// Streams the on-disk download cache from [DownloadsRepository].
class DownloadedTracksCubit extends Cubit<List<DownloadedTrack>> {
  StreamSubscription<List<DownloadedTrack>>? _sub;

  DownloadedTracksCubit({required DownloadsRepository repository})
    : super(const []) {
    _sub = repository.watchDownloadedTracks().listen(emit);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
