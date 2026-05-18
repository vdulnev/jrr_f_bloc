import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../offline/data/models/download_state.dart';
import '../../offline/data/repositories/downloads_repository.dart';
import '../../offline/download_jobs_service.dart';
import '../../offline/downloaded_tracks_service.dart';
import '../../offline/widgets/confirm_delete_dialog.dart';
import '../../offline/widgets/download_progress_indicator.dart';
import '../../player/bloc/player_controller_cubit.dart';
import '../../zones/active_zone_service.dart';
import '../bloc/library_item_tile_cubit.dart';
import '../data/models/track.dart';

/// Track row used in album / folder / search lists. Owns one paired
/// [LibraryItemTileCubit] that folds the active zone + per-track
/// download status into a single record.
class LibraryItemTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider<LibraryItemTileCubit>(
      key: ValueKey('lib-tile-${item.fileKey}'),
      create: (_) => LibraryItemTileCubit(
        track: item,
        activeZone: getIt<ActiveZoneService>(),
        tracks: getIt<DownloadedTracksService>(),
        jobs: getIt<DownloadJobsService>(),
        repo: getIt<DownloadsRepository>(),
      ),
      child: _Tile(
        item: item,
        trackNumber: trackNumber,
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  final Track item;
  final int? trackNumber;

  const _Tile({required this.item, required this.trackNumber});

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
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
          BlocBuilder<LibraryItemTileCubit, LibraryItemTileViewState>(
            builder: (context, view) {
              if (view.isOffline && view.status != DownloadState.downloaded) {
                return const SizedBox(width: 18);
              }
              return _Menu(
                item: item,
                status: view.status,
                isOffline: view.isOffline,
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
    final cubit = context.read<LibraryItemTileCubit>();
    final controller = context.read<PlayerControllerCubit>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    switch (action) {
      case 'play':
        await cubit.play(controller);
      case 'playNext':
        await cubit.playNext(controller);
      case 'add':
        await cubit.add(controller);
        messenger?.showSnackBar(
          const SnackBar(
            content: Text('Added to playing now'),
            duration: Duration(seconds: 1),
          ),
        );
      case 'download':
        await cubit.download();
      case 'cancelDownload':
        await cubit.cancelDownload();
      case 'deleteDownload':
        if (!context.mounted) return;
        final confirmed = await showConfirmDeleteDialog(
          context: context,
          title: 'Delete Download',
          message: 'Delete downloaded track "${item.name}"?',
        );
        if (confirmed) await cubit.deleteDownload();
    }
  }
}
