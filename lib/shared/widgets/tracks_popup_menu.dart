import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../features/library/data/models/tracks.dart';
import '../../features/offline/data/repositories/downloads_repository.dart';
import '../../features/offline/download_jobs_service.dart';
import '../../features/offline/downloaded_tracks_service.dart';
import '../../features/player/bloc/player_controller_cubit.dart';
import '../../features/zones/active_zone_service.dart';
import 'tracks_popup_menu_cubit.dart';

/// Compact popup menu for a group of tracks. Play / Play next / Add are
/// always present; download / cancel / delete entries appear based on
/// the current download state. Bound to one paired [TracksPopupMenuCubit]
/// that derives the boolean visibility flags from the services.
class TracksPopupMenu extends StatelessWidget {
  final Tracks tracks;
  final String? label;

  const TracksPopupMenu({required this.tracks, this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TracksPopupMenuCubit>(
      create: (_) => TracksPopupMenuCubit(
        tracks: tracks.tracks,
        activeZone: getIt<ActiveZoneService>(),
        tracksService: getIt<DownloadedTracksService>(),
        jobs: getIt<DownloadJobsService>(),
        repo: getIt<DownloadsRepository>(),
      ),
      child: _Body(tracks: tracks, label: label),
    );
  }
}

class _Body extends StatelessWidget {
  final Tracks tracks;
  final String? label;

  const _Body({required this.tracks, this.label});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TracksPopupMenuCubit, TracksPopupMenuViewState>(
      builder: (context, view) {
        if (view.hidden) return const SizedBox(width: 18);
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
            if (view.showDownload ||
                view.showRetry ||
                view.showCancel ||
                view.showDelete)
              const PopupMenuDivider(),
            if (view.showDownload)
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download_for_offline_outlined),
                  title: Text('Download all'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (view.showRetry)
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.replay_outlined),
                  title: Text('Retry failed downloads'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (view.showCancel)
              const PopupMenuItem(
                value: 'cancelDownload',
                child: ListTile(
                  leading: Icon(Icons.cancel_outlined),
                  title: Text('Cancel downloads'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (view.showDelete)
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
        );
      },
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    final cubit = context.read<TracksPopupMenuCubit>();
    final controller = context.read<PlayerControllerCubit>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    switch (action) {
      case 'play':
        await cubit.play(controller);
      case 'playNext':
        await cubit.playNext(controller);
      case 'add':
        await cubit.add(controller);
        if (label != null) {
          messenger?.showSnackBar(
            SnackBar(
              content: Text('Added "$label" to playing now'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      case 'download':
        await cubit.download();
        if (label != null) {
          messenger?.showSnackBar(
            SnackBar(
              content: Text('Downloading "$label"'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      case 'cancelDownload':
        await cubit.cancelDownload();
      case 'deleteDownload':
        await cubit.deleteDownload();
    }
  }
}
