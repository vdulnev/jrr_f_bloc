import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../bloc/library_async_state.dart';
import '../bloc/random_albums_cubit.dart';
import '../data/models/album_group.dart';
import '../data/models/albums.dart';
import 'album_list_view.dart';

class RandomTab extends StatelessWidget {
  const RandomTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomAlbumsCubit, LibAsync<Albums>>(
      builder: (context, state) => switch (state) {
        LibLoading<Albums>() => const LoadingView(),
        LibError<Albums>(:final error) => ErrorView(
          error: error,
          onRetry: () => context.read<RandomAlbumsCubit>().load(),
        ),
        LibData<Albums>(:final value) when value.albums.isEmpty => const Center(
          child: Text('No albums', style: AppTextStyles.emptyState),
        ),
        LibData<Albums>(:final value) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => context.read<RandomAlbumsCubit>().load(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.line2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Shuffle',
                        style: AppTextStyles.accentSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AlbumListView(
                groups: [
                  for (final a in value.albums) AlbumGroup(album: a),
                ],
              ),
            ),
          ],
        ),
      },
    );
  }
}
