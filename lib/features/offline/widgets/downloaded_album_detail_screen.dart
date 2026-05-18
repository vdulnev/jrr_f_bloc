import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../library/bloc/library_async_state.dart';
import '../../library/widgets/track_list_scaffold.dart';
import '../bloc/downloaded_album_detail_cubit.dart';
import '../downloaded_tracks_service.dart';

@RoutePage()
class DownloadedAlbumDetailScreen extends StatelessWidget {
  final String albumGroupId;

  const DownloadedAlbumDetailScreen({required this.albumGroupId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadedAlbumDetailCubit>(
      create: (_) => DownloadedAlbumDetailCubit(
        albumGroupId: albumGroupId,
        service: getIt<DownloadedTracksService>(),
      ),
      child:
          BlocBuilder<DownloadedAlbumDetailCubit, DownloadedAlbumDetailState>(
            builder: (context, tracks) {
              final first = tracks.tracks.isNotEmpty
                  ? tracks.tracks.first
                  : null;
              return TrackListScaffold(
                title: Text(
                  first?.album ?? 'Album',
                  style: AppTextStyles.subScreenTitle,
                ),
                subtitle: first == null
                    ? 'Downloaded Album'
                    : [
                        first.albumArtistAuto,
                        first.dateReadable,
                      ].where((s) => s.isNotEmpty).join(' · '),
                tracksState: LibAsync.data(value: tracks),
                onRetry: () {},
                actionSheetTitle: 'Album',
                addedSnackbarLabel: 'Album',
                emptyState: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off_outlined,
                        size: 56,
                        color: AppColors.text3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Album has 0 tracks downloaded',
                        style: AppTextStyles.emptyState,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
