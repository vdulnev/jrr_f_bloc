import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/sub_screen_header.dart';
import '../bloc/artist_albums_cubit.dart';
import '../bloc/library_async_state.dart';
import '../data/models/album_group.dart';
import '../data/repositories/library_repository.dart';
import 'album_list_view.dart';

@RoutePage()
class ArtistAlbumsScreen extends StatelessWidget {
  final String artist;
  const ArtistAlbumsScreen({required this.artist, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtistAlbumsCubit(
        artist: artist,
        repository: getIt<LibraryRepository>(),
        talker: getIt(),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubScreenHeader(
                titleWidget: Text(artist, style: AppTextStyles.subScreenTitle),
                subtitle: 'Albums',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(child: _Body()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistAlbumsCubit, LibAsync<List<AlbumGroup>>>(
      builder: (context, state) => switch (state) {
        LibLoading<List<AlbumGroup>>() => const LoadingView(),
        LibError<List<AlbumGroup>>(:final error) => ErrorView(
          error: error,
          onRetry: () => context.read<ArtistAlbumsCubit>().load(),
        ),
        LibData<List<AlbumGroup>>(:final value) when value.isEmpty =>
          const Center(child: Text('No albums', style: AppTextStyles.emptyState)),
        LibData<List<AlbumGroup>>(:final value) =>
          AlbumListView(groups: value, showArtist: false),
      },
    );
  }
}
