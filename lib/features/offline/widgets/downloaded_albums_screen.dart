import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/string_extensions.dart';
import '../../../shared/widgets/sub_screen_header.dart';
import '../../library/data/models/album.dart';
import '../../library/widgets/album_row_tile.dart';
import '../bloc/downloaded_tracks_cubit.dart';
import '../data/models/downloaded_track.dart';
import 'downloaded_navigation.dart';

List<Album> _albumsForArtist(List<DownloadedTrack> all, String artist) {
  final groups = <String, Album>{};
  for (final t in all) {
    final tArtist =
        t.albumArtist.isEmpty ? 'Unknown Artist' : t.albumArtist;
    if (!tArtist.equalsIgnoreCase(artist)) continue;
    groups.putIfAbsent(t.albumGroupId, () => Album.fromTrack(t.track));
  }
  final albums = groups.values.toList()
    ..sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return a.name.compareTo(b.name);
    });
  return albums;
}

class DownloadedAlbumsScreen extends StatelessWidget {
  final String artist;

  const DownloadedAlbumsScreen({required this.artist, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SubScreenHeader(
              titleWidget: Text(artist, style: AppTextStyles.subScreenTitle),
              subtitle: 'Downloaded Albums',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: BlocBuilder<DownloadedTracksCubit, List<DownloadedTrack>>(
                builder: (context, all) {
                  final albums = _albumsForArtist(all, artist);
                  if (albums.isEmpty) return const _EmptyAlbums();
                  return ListView.builder(
                    itemCount: albums.length,
                    itemBuilder: (_, i) {
                      final album = albums[i];
                      return AlbumRowTile(
                        album: album,
                        onTap: () => pushDownloadedAlbumDetail(
                          context,
                          album.albumGroupId,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlbums extends StatelessWidget {
  const _EmptyAlbums();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.album_outlined, size: 56, color: AppColors.text3),
          SizedBox(height: 16),
          Text('No downloaded albums', style: AppTextStyles.emptyState),
          SizedBox(height: 8),
          Text(
            'Downloads from this artist will appear here',
            style: AppTextStyles.itemSubtitle,
          ),
        ],
      ),
    );
  }
}
