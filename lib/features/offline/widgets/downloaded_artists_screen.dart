import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../player/bloc/player_controller_cubit.dart';
import '../bloc/downloaded_artists_cubit.dart';
import '../data/models/downloaded_track.dart';
import '../data/repositories/downloads_repository.dart';
import '../downloaded_tracks_service.dart';
import 'confirm_delete_dialog.dart';
import 'downloaded_navigation.dart';

class DownloadedArtistsScreen extends StatelessWidget {
  const DownloadedArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadedArtistsCubit>(
      create: (_) => DownloadedArtistsCubit(
        service: getIt<DownloadedTracksService>(),
        repo: getIt<DownloadsRepository>(),
      ),
      child: BlocBuilder<DownloadedArtistsCubit, DownloadedArtistsState>(
        builder: (context, state) {
          if (state.isEmpty) return const _EmptyState();
          return CustomScrollView(
            slivers: [
              SliverList.builder(
                itemCount: state.length,
                itemBuilder: (_, i) => _ArtistRow(
                  artist: state[i].artist,
                  tracks: state[i].tracks,
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          );
        },
      ),
    );
  }
}

class _ArtistRow extends StatelessWidget {
  final String artist;
  final List<DownloadedTrack> tracks;

  const _ArtistRow({required this.artist, required this.tracks});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => pushDownloadedAlbums(context, artist),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bg3,
              ),
              alignment: Alignment.center,
              child: Text(
                artist.isNotEmpty ? artist[0].toUpperCase() : '?',
                style: AppTextStyles.avatarLetter,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(artist, style: AppTextStyles.itemTitle)),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.text3,
              ),
              padding: EdgeInsets.zero,
              onSelected: (action) => _handleAction(context, action),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'play',
                  child: ListTile(
                    leading: Icon(Icons.play_arrow_outlined),
                    title: Text('Play'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                PopupMenuItem(
                  value: 'playNext',
                  child: ListTile(
                    leading: Icon(Icons.queue_play_next),
                    title: Text('Play next'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                PopupMenuItem(
                  value: 'add',
                  child: ListTile(
                    leading: Icon(Icons.add_circle_outline),
                    title: Text('Add to playing now'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    final cubit = context.read<DownloadedArtistsCubit>();
    final controller = context.read<PlayerControllerCubit>();
    switch (action) {
      case 'play':
        await cubit.play(tracks, controller);
      case 'playNext':
        await cubit.playNext(tracks, controller);
      case 'add':
        await cubit.add(tracks, controller);
      case 'deleteDownload':
        if (!context.mounted) return;
        final confirmed = await showConfirmDeleteDialog(
          context: context,
          title: 'Delete downloads?',
          message:
              'Delete all ${tracks.length} downloaded tracks for "$artist"?',
        );
        if (confirmed) await cubit.delete(tracks);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_for_offline_outlined,
            size: 64,
            color: AppColors.text3,
          ),
          SizedBox(height: 16),
          Text('No downloads yet', style: AppTextStyles.emptyState),
          SizedBox(height: 8),
          Text(
            'Tracks you download will appear here',
            style: AppTextStyles.itemSubtitle,
          ),
        ],
      ),
    );
  }
}
