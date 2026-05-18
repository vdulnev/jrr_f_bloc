import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/sub_screen_header.dart';
import '../../library/widgets/album_row_tile.dart';
import '../bloc/downloaded_albums_cubit.dart';
import '../downloaded_tracks_service.dart';
import 'downloaded_navigation.dart';

@RoutePage()
class DownloadedAlbumsScreen extends StatelessWidget {
  final String artist;

  const DownloadedAlbumsScreen({required this.artist, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadedAlbumsCubit>(
      create: (_) => DownloadedAlbumsCubit(
        artist: artist,
        service: getIt<DownloadedTracksService>(),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SubScreenHeader(
                titleWidget: Text(artist, style: AppTextStyles.subScreenTitle),
                subtitle: 'Downloaded Albums',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child:
                    BlocBuilder<DownloadedAlbumsCubit, DownloadedAlbumsState>(
                      builder: (context, state) {
                        if (state.isEmpty) return const _EmptyAlbums();
                        return ListView.builder(
                          itemCount: state.length,
                          itemBuilder: (_, i) {
                            final album = state[i];
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
