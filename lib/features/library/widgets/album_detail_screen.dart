import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../bloc/album_tracks_cubit.dart';
import '../bloc/library_async_state.dart';
import '../data/models/album.dart';
import '../data/models/tracks.dart';
import '../data/repositories/library_repository.dart';
import 'track_list_scaffold.dart';

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({required this.album, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlbumTracksCubit(
        album: album,
        repository: getIt<LibraryRepository>(),
      ),
      child: BlocBuilder<AlbumTracksCubit, LibAsync<Tracks>>(
        builder: (context, state) => TrackListScaffold(
          subtitle: album.albumArtist,
          onBack: () => Navigator.of(context).maybePop(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  album.date,
                  album.name,
                  if (album.totalDiscs > 1 && album.discNumber > 0)
                    'Disc ${album.discNumber}/${album.totalDiscs}',
                ].where((s) => s.isNotEmpty).join(' - '),
              ),
              if (album.albumArtist.isNotEmpty)
                Text(
                  album.albumArtist,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          tracksState: state,
          onRetry: () => context.read<AlbumTracksCubit>().load(),
          actionSheetTitle: album.name,
          addedSnackbarLabel: album.name,
        ),
      ),
    );
  }
}
