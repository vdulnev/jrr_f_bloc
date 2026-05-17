import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/download_jobs_cubit.dart';
import '../bloc/download_status.dart';
import '../data/models/download_job.dart';
import '../data/models/download_state.dart';

class AlbumDownloadProgressIndicator extends StatelessWidget {
  final String albumGroupId;
  final double size;

  const AlbumDownloadProgressIndicator({
    required this.albumGroupId,
    this.size = 14,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadJobsCubit, List<DownloadJob>>(
      builder: (context, jobs) {
        final status = DownloadStatus.forAlbum(
          albumGroupId: albumGroupId,
          jobs: jobs,
        );
        final progress = DownloadStatus.progressForAlbum(
          albumGroupId: albumGroupId,
          jobs: jobs,
        );

        switch (status) {
          case DownloadState.queued:
            return SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.text3),
              ),
            );
          case DownloadState.running:
            return SizedBox(
              width: size,
              height: size,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                builder: (_, value, _) => CircularProgressIndicator(
                  value: value > 0 ? value : null,
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent,
                  ),
                ),
              ),
            );
          case DownloadState.failed:
            return Icon(
              Icons.error_outline_rounded,
              size: size,
              color: AppColors.error,
            );
          case DownloadState.downloaded:
          case DownloadState.notDownloaded:
          case DownloadState.cancelled:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
