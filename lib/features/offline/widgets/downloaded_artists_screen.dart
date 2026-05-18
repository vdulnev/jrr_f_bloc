import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../library/data/models/tracks.dart';
import '../../player/bloc/player_controller_cubit.dart';
import '../data/models/downloaded_track.dart';
import '../data/repositories/downloads_repository.dart';
import '../downloaded_tracks_service.dart';
import 'confirm_delete_dialog.dart';
import 'downloaded_navigation.dart';

String _normalizedArtist(DownloadedTrack t) =>
    t.albumArtist.isEmpty ? 'Unknown Artist' : t.albumArtist;

List<String> _artistsFrom(List<DownloadedTrack> tracks) {
  final artists = tracks.map(_normalizedArtist).toSet().toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return artists;
}

class DownloadedArtistsScreen extends StatelessWidget {
  const DownloadedArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = getIt<DownloadedTracksService>();
    return StreamBuilder<List<DownloadedTrack>>(
      stream: service.stream,
      initialData: service.state,
      builder: (context, snap) {
        final downloaded = snap.data ?? service.state;
        final artists = _artistsFrom(downloaded);
        if (artists.isEmpty) return const _EmptyState();
        return CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: artists.length,
              itemBuilder: (_, i) => _ArtistRow(
                artist: artists[i],
                tracks: downloaded
                    .where((t) => _normalizedArtist(t) == artists[i])
                    .toList(),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        );
      },
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
    final sortedTracks = tracks.map((t) => t.track).toList()
      ..sort((a, b) {
        final albumCompare = a.album.compareTo(b.album);
        if (albumCompare != 0) return albumCompare;
        final discCompare = a.discNumber.compareTo(b.discNumber);
        if (discCompare != 0) return discCompare;
        return a.trackNumber.compareTo(b.trackNumber);
      });
    if (sortedTracks.isEmpty) return;

    final wrapped = Tracks(tracks: sortedTracks);
    final controller = context.read<PlayerControllerCubit>();
    switch (action) {
      case 'play':
        await controller.playNow(wrapped);
      case 'playNext':
        await controller.playNext(wrapped);
      case 'add':
        await controller.addToQueue(wrapped);
      case 'deleteDownload':
        if (!context.mounted) return;
        final confirmed = await showConfirmDeleteDialog(
          context: context,
          title: 'Delete downloads?',
          message:
              'Delete all ${sortedTracks.length} downloaded tracks for "$artist"?',
        );
        if (!confirmed) return;
        await getIt<DownloadsRepository>().deleteAll(
          sortedTracks.map((t) => t.fileKey).toList(),
        );
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
