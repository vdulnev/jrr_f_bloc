import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../features/library/data/models/tracks.dart';
import '../../features/offline/bloc/download_jobs_cubit.dart';
import '../../features/offline/bloc/downloaded_tracks_cubit.dart';
import '../../features/offline/data/models/download_job.dart';
import '../../features/offline/data/models/download_state.dart';
import '../../features/offline/data/models/downloaded_track.dart';
import '../../features/offline/data/repositories/downloads_repository.dart';
import '../../features/player/bloc/player_controller_cubit.dart';
import '../../features/zones/active_zone_service.dart';
import '../../features/zones/data/models/zone.dart';

/// Compact popup menu for a group of tracks. Play / Play next / Add are
/// always present; download / cancel / delete entries appear based on the
/// current set of downloaded tracks and active jobs, hidden in offline
/// mode when nothing in the group is on-disk.
class TracksPopupMenu extends StatelessWidget {
  final Tracks tracks;
  final String? label;

  const TracksPopupMenu({required this.tracks, this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final service = getIt<ActiveZoneService>();
    return StreamBuilder<Zone?>(
      stream: service.stream,
      initialData: service.state,
      builder: (context, snap) {
        final activeZone = snap.data ?? service.state;
        final isOffline = activeZone?.isOffline == true;
        return BlocBuilder<DownloadedTracksCubit, List<DownloadedTrack>>(
          builder: (context, downloaded) =>
              BlocBuilder<DownloadJobsCubit, List<DownloadJob>>(
                builder: (context, jobs) =>
                    _build(context, isOffline, downloaded, jobs),
              ),
        );
      },
    );
  }

  Widget _build(
    BuildContext context,
    bool isOffline,
    List<DownloadedTrack> downloaded,
    List<DownloadJob> jobs,
  ) {
    final trackKeys = tracks.tracks.map((t) => t.fileKey).toSet();
    final downloadedKeys = downloaded
        .where((t) => trackKeys.contains(t.fileKey))
        .map((t) => t.fileKey)
        .toSet();

    if (isOffline && downloadedKeys.isEmpty) {
      return const SizedBox(width: 18);
    }

    final jobsForTracks = jobs
        .where((j) => trackKeys.contains(j.fileKey))
        .toList();
    final activeJobs = jobsForTracks.where(
      (j) =>
          j.state == DownloadState.queued || j.state == DownloadState.running,
    );
    final failedJobs = jobsForTracks.where(
      (j) => j.state == DownloadState.failed,
    );

    final showDownload =
        !isOffline &&
        downloadedKeys.length < tracks.length &&
        activeJobs.isEmpty;
    final showCancel = !isOffline && activeJobs.isNotEmpty;
    final showDelete = downloadedKeys.isNotEmpty;
    final showRetry = !isOffline && failedJobs.isNotEmpty && activeJobs.isEmpty;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.text3),
      padding: EdgeInsets.zero,
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'play',
          child: ListTile(
            leading: Icon(Icons.play_arrow_outlined),
            title: Text('Play'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const PopupMenuItem(
          value: 'playNext',
          child: ListTile(
            leading: Icon(Icons.queue_play_next),
            title: Text('Play next'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const PopupMenuItem(
          value: 'add',
          child: ListTile(
            leading: Icon(Icons.add_circle_outline),
            title: Text('Add to playing now'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        if (showDownload || showRetry || showCancel || showDelete)
          const PopupMenuDivider(),
        if (showDownload)
          const PopupMenuItem(
            value: 'download',
            child: ListTile(
              leading: Icon(Icons.download_for_offline_outlined),
              title: Text('Download all'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (showRetry)
          const PopupMenuItem(
            value: 'download',
            child: ListTile(
              leading: Icon(Icons.replay_outlined),
              title: Text('Retry failed downloads'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (showCancel)
          const PopupMenuItem(
            value: 'cancelDownload',
            child: ListTile(
              leading: Icon(Icons.cancel_outlined),
              title: Text('Cancel downloads'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (showDelete)
          const PopupMenuItem(
            value: 'deleteDownload',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Delete downloads',
                style: TextStyle(color: AppColors.error),
              ),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    final controller = context.read<PlayerControllerCubit>();
    final repo = getIt<DownloadsRepository>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    switch (action) {
      case 'play':
        await controller.playNow(tracks);
      case 'playNext':
        await controller.playNext(tracks);
      case 'add':
        await controller.addToQueue(tracks);
        if (label != null) {
          messenger?.showSnackBar(
            SnackBar(
              content: Text('Added "$label" to playing now'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      case 'download':
        await repo.enqueueAll(tracks.tracks);
        if (label != null) {
          messenger?.showSnackBar(
            SnackBar(
              content: Text('Downloading "$label"'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      case 'cancelDownload':
        await repo.cancelAll(tracks.tracks.map((t) => t.fileKey).toList());
      case 'deleteDownload':
        await repo.deleteAll(tracks.tracks.map((t) => t.fileKey).toList());
    }
    await controller.refresh();
  }
}
