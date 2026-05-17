import '../data/models/download_job.dart';
import '../data/models/download_state.dart';
import '../data/models/downloaded_track.dart';

/// Pure helpers for combining downloaded-tracks and download-jobs into
/// the per-track / per-album status the UI shows. Used directly inside
/// `BlocBuilder` builders, avoiding a per-key cubit family.
class DownloadStatus {
  static DownloadState forTrack({
    required int fileKey,
    required List<DownloadedTrack> downloaded,
    required List<DownloadJob> jobs,
  }) {
    if (downloaded.any((t) => t.fileKey == fileKey)) {
      return DownloadState.downloaded;
    }
    final job = jobs.where((j) => j.fileKey == fileKey).firstOrNull;
    return job?.state ?? DownloadState.notDownloaded;
  }

  static double progressForTrack({
    required int fileKey,
    required List<DownloadJob> jobs,
  }) {
    final job = jobs.where((j) => j.fileKey == fileKey).firstOrNull;
    if (job == null || job.bytesTotal <= 0) return 0;
    return job.bytesDone / job.bytesTotal;
  }

  static DownloadState forAlbum({
    required String albumGroupId,
    required List<DownloadJob> jobs,
  }) {
    final albumJobs =
        jobs.where((j) => j.track.albumGroupId == albumGroupId).toList();
    if (albumJobs.isEmpty) return DownloadState.notDownloaded;
    if (albumJobs.any((j) => j.state == DownloadState.running)) {
      return DownloadState.running;
    }
    if (albumJobs.any((j) => j.state == DownloadState.queued)) {
      return DownloadState.queued;
    }
    if (albumJobs.any((j) => j.state == DownloadState.failed)) {
      return DownloadState.failed;
    }
    return DownloadState.notDownloaded;
  }

  static double progressForAlbum({
    required String albumGroupId,
    required List<DownloadJob> jobs,
  }) {
    final albumJobs =
        jobs.where((j) => j.track.albumGroupId == albumGroupId).toList();
    if (albumJobs.isEmpty) return 0;

    var totalBytesDone = 0;
    var totalBytesTotal = 0;
    for (final job in albumJobs) {
      if (job.bytesTotal > 0) {
        totalBytesDone += job.bytesDone;
        totalBytesTotal += job.bytesTotal;
      }
    }
    if (totalBytesTotal <= 0) {
      final completed = albumJobs
          .where((j) => j.state == DownloadState.downloaded)
          .length;
      return completed / albumJobs.length;
    }
    return totalBytesDone / totalBytesTotal;
  }
}
