import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/artwork_widget.dart';
import '../../offline/bloc/download_jobs_cubit.dart';
import '../../offline/bloc/downloaded_tracks_cubit.dart';
import '../../offline/data/models/download_job.dart';
import '../../offline/data/models/download_state.dart';
import '../../offline/data/models/downloaded_track.dart';
import '../../offline/data/repositories/downloads_repository.dart';
import '../../offline/widgets/album_download_progress_indicator.dart';
import '../../offline/widgets/confirm_delete_dialog.dart';
import '../../offline/widgets/downloaded_navigation.dart';
import '../../player/bloc/player_controller_cubit.dart';
import '../../zones/active_zone_service.dart';
import '../../zones/data/models/zone.dart';
import '../data/models/album.dart';
import '../data/models/tracks.dart';
import '../data/repositories/library_repository.dart';
import 'library_navigation.dart';

/// Album row used in artist / random / album lists. Phase 8 layers in:
/// • album-level download progress indicator
/// • status-aware popup entries (download / cancel / delete)
/// • offline-mode visibility (hidden when nothing from the album is on
///   disk)
/// • tap routes to the downloaded-album-detail screen when offline.
class AlbumRowTile extends StatelessWidget {
  final Album album;
  final bool showArtist;
  final double indent;
  final String? titleOverride;
  final VoidCallback? onTap;
  final bool hasSubItems;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const AlbumRowTile({
    required this.album,
    this.showArtist = true,
    this.indent = 0,
    this.titleOverride,
    this.onTap,
    this.hasSubItems = false,
    this.isExpanded = false,
    this.onToggle,
    super.key,
  });

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
                builder: (context, jobs) {
                  final downloadedInAlbum = downloaded
                      .where((t) => t.albumGroupId == album.albumGroupId)
                      .toList();
                  if (isOffline && downloadedInAlbum.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final jobsInAlbum = jobs
                      .where((j) => j.track.albumGroupId == album.albumGroupId)
                      .toList();
                  final activeJobs = jobsInAlbum.where(
                    (j) =>
                        j.state == DownloadState.queued ||
                        j.state == DownloadState.running,
                  );
                  final failedJobs = jobsInAlbum.where(
                    (j) => j.state == DownloadState.failed,
                  );
                  return _Row(
                    album: album,
                    showArtist: showArtist,
                    indent: indent,
                    titleOverride: titleOverride,
                    onTap:
                        onTap ??
                        () => isOffline
                            ? pushDownloadedAlbumDetail(
                                context,
                                album.albumGroupId,
                              )
                            : pushAlbumDetail(context, album),
                    hasSubItems: hasSubItems,
                    isExpanded: isExpanded,
                    onToggle: onToggle,
                    isOffline: isOffline,
                    showDownload: !isOffline && activeJobs.isEmpty,
                    showCancel: !isOffline && activeJobs.isNotEmpty,
                    showDelete: downloadedInAlbum.isNotEmpty,
                    showRetry:
                        !isOffline &&
                        failedJobs.isNotEmpty &&
                        activeJobs.isEmpty,
                  );
                },
              ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final Album album;
  final bool showArtist;
  final double indent;
  final String? titleOverride;
  final VoidCallback onTap;
  final bool hasSubItems;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final bool isOffline;
  final bool showDownload;
  final bool showCancel;
  final bool showDelete;
  final bool showRetry;

  const _Row({
    required this.album,
    required this.showArtist,
    required this.indent,
    required this.titleOverride,
    required this.onTap,
    required this.hasSubItems,
    required this.isExpanded,
    required this.onToggle,
    required this.isOffline,
    required this.showDownload,
    required this.showCancel,
    required this.showDelete,
    required this.showRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(20 + indent, 12, 20, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ArtworkWidget(
                fileKey: album.artworkFileKey,
                size: indent > 0 ? 32 : 48,
              ),
            ),
            SizedBox(width: indent > 0 ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleOverride ??
                        [
                          album.date,
                          album.name,
                          if (album.totalDiscs > 1 && album.discNumber > 0)
                            'Disc ${album.discNumber}/${album.totalDiscs}',
                        ].where((s) => s.isNotEmpty).join(' - '),
                    style: indent > 0
                        ? AppTextStyles.labelLarge
                        : AppTextStyles.itemTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    showArtist ? album.albumArtist : album.folderPath,
                    style: AppTextStyles.itemSubtitle,
                    maxLines: showArtist ? 1 : (indent > 0 ? 1 : null),
                    overflow: showArtist
                        ? TextOverflow.ellipsis
                        : (indent > 0
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible),
                    softWrap: !showArtist && indent == 0,
                  ),
                ],
              ),
            ),
            if (hasSubItems && !isOffline)
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.text3,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onToggle,
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: AlbumDownloadProgressIndicator(
                albumGroupId: album.albumGroupId,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.text3,
              ),
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
                if (album.folderPath.isNotEmpty && !isOffline)
                  const PopupMenuItem(
                    value: 'folder',
                    child: ListTile(
                      leading: Icon(Icons.folder_open_outlined),
                      title: Text('Open folder'),
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
                      title: Text('Download album'),
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
                      leading: Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      title: Text(
                        'Delete downloads',
                        style: TextStyle(color: AppColors.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    if (action == 'folder') {
      pushFolderTracks(context, album.folderPath);
      return;
    }
    final controller = context.read<PlayerControllerCubit>();
    final repo = getIt<DownloadsRepository>();
    final library = getIt<LibraryRepository>();
    final downloads = context.read<DownloadedTracksCubit>().state;

    Tracks? resolveAlbumTracks() {
      if (isOffline) {
        final filtered =
            downloads
                .where((t) => t.albumGroupId == album.albumGroupId)
                .map((t) => t.track)
                .toList()
              ..sort((a, b) {
                final discCompare = a.discNumber.compareTo(b.discNumber);
                if (discCompare != 0) return discCompare;
                return a.trackNumber.compareTo(b.trackNumber);
              });
        return Tracks(tracks: filtered);
      }
      return null;
    }

    if (action == 'cancelDownload' || action == 'deleteDownload') {
      final tracks =
          resolveAlbumTracks() ??
          (await library.getAlbumTracks(album)).match((_) => null, (t) => t);
      if (tracks == null) return;
      final keys = tracks.tracks.map((t) => t.fileKey).toList();
      if (action == 'cancelDownload') {
        await repo.cancelAll(keys);
      } else {
        if (!context.mounted) return;
        final confirmed = await showConfirmDeleteDialog(
          context: context,
          title: 'Delete downloads?',
          message:
              'Delete ${keys.length} downloaded tracks from "${album.name}"?',
        );
        if (!confirmed) return;
        await repo.deleteAll(keys);
      }
      return;
    }

    final tracks =
        resolveAlbumTracks() ??
        (await library.getAlbumTracks(album)).match((_) => null, (t) => t);
    if (tracks == null) return;
    switch (action) {
      case 'play':
        await controller.playNow(tracks);
      case 'playNext':
        await controller.playNext(tracks);
      case 'add':
        await controller.addToQueue(tracks);
      case 'download':
        await repo.enqueueAll(tracks.tracks);
    }
    await controller.refresh();
  }
}
