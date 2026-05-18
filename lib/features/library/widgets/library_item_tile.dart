import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../offline/bloc/download_jobs_cubit.dart';
import '../../offline/bloc/download_status.dart';
import '../../offline/bloc/downloaded_tracks_cubit.dart';
import '../../offline/data/models/download_job.dart';
import '../../offline/data/models/download_state.dart';
import '../../offline/data/models/downloaded_track.dart';
import '../../offline/data/repositories/downloads_repository.dart';
import '../../offline/widgets/confirm_delete_dialog.dart';
import '../../offline/widgets/download_progress_indicator.dart';
import '../../player/bloc/player_controller_cubit.dart';
import '../../zones/active_zone_service.dart';
import '../../zones/data/models/zone.dart';
import '../data/models/track.dart';
import '../data/models/tracks.dart';

/// Track row used in album / folder / search lists. Phase 8 layers in
/// download chrome: per-track progress, status-aware popup entries, and
/// offline-mode visibility rules.
class LibraryItemTile extends StatefulWidget {
  final Track item;
  final int? trackNumber;
  final bool collapsedByDefault;

  const LibraryItemTile({
    required this.item,
    this.trackNumber,
    this.collapsedByDefault = false,
    super.key,
  });

  @override
  State<LibraryItemTile> createState() => _LibraryItemTileState();
}

class _LibraryItemTileState extends State<LibraryItemTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final displayTrackNumber =
        widget.trackNumber ?? (item.trackNumber > 0 ? item.trackNumber : null);
    return ListTile(
      leading: displayTrackNumber != null
          ? SizedBox(
              width: 32,
              child: Text(
                '$displayTrackNumber',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : null,
      title: Text(
        item.name.isNotEmpty ? item.name : 'Unknown',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              [
                item.dateReadable,
                item.album,
              ].where((s) => s.isNotEmpty).join(' - '),
              item.artist,
            ].where((s) => s.isNotEmpty).join(' · '),
            style: AppTextStyles.itemSubtitle,
          ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            Text(
              item.folderPath,
              style: AppTextStyles.monoLabel.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 2),
            Text(
              item.filePath,
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 10,
                color: AppColors.text3,
              ),
            ),
          ],
        ],
      ),
      onTap: () => setState(() => _expanded = !_expanded),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DownloadProgressIndicator(fileKey: item.fileKey),
          const SizedBox(width: 4),
          Builder(
            builder: (context) {
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
                          builder: (context, jobs) {
                            final status = DownloadStatus.forTrack(
                              fileKey: item.fileKey,
                              downloaded: downloaded,
                              jobs: jobs,
                            );
                            if (isOffline &&
                                status != DownloadState.downloaded) {
                              return const SizedBox(width: 18);
                            }
                            return _Menu(
                              item: item,
                              status: status,
                              isOffline: isOffline,
                            );
                          },
                        ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final Track item;
  final DownloadState status;
  final bool isOffline;

  const _Menu({
    required this.item,
    required this.status,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
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
        const PopupMenuDivider(),
        if (!isOffline && status == DownloadState.notDownloaded)
          const PopupMenuItem(
            value: 'download',
            child: ListTile(
              leading: Icon(Icons.download_for_offline_outlined),
              title: Text('Download'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (!isOffline &&
            (status == DownloadState.queued || status == DownloadState.running))
          const PopupMenuItem(
            value: 'cancelDownload',
            child: ListTile(
              leading: Icon(Icons.cancel_outlined),
              title: Text('Cancel download'),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (status == DownloadState.downloaded)
          const PopupMenuItem(
            value: 'deleteDownload',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Delete download',
                style: TextStyle(color: AppColors.error),
              ),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (!isOffline && status == DownloadState.failed)
          const PopupMenuItem(
            value: 'download',
            child: ListTile(
              leading: Icon(Icons.replay_outlined),
              title: Text('Retry download'),
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
    final tracks = Tracks(tracks: [item]);
    final messenger = ScaffoldMessenger.maybeOf(context);
    switch (action) {
      case 'play':
        await controller.playNow(tracks);
      case 'playNext':
        await controller.playNext(tracks);
      case 'add':
        await controller.addToQueue(tracks);
        messenger?.showSnackBar(
          const SnackBar(
            content: Text('Added to playing now'),
            duration: Duration(seconds: 1),
          ),
        );
      case 'download':
        await repo.enqueue(item);
      case 'cancelDownload':
        await repo.cancel(item.fileKey);
      case 'deleteDownload':
        if (!context.mounted) return;
        final confirmed = await showConfirmDeleteDialog(
          context: context,
          title: 'Delete Download',
          message: 'Delete downloaded track "${item.name}"?',
        );
        if (confirmed) await repo.delete(item.fileKey);
    }
  }
}
