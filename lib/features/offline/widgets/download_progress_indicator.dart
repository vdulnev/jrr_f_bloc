import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/download_progress_cubit.dart';
import '../data/models/download_state.dart';
import '../download_jobs_service.dart';
import '../downloaded_tracks_service.dart';

class DownloadProgressIndicator extends StatelessWidget {
  final int fileKey;
  final double size;

  const DownloadProgressIndicator({
    required this.fileKey,
    this.size = 14,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadProgressCubit>(
      key: ValueKey('download-progress-$fileKey'),
      create: (_) => DownloadProgressCubit(
        fileKey: fileKey,
        tracks: getIt<DownloadedTracksService>(),
        jobs: getIt<DownloadJobsService>(),
      ),
      child: _Body(size: size),
    );
  }
}

class _Body extends StatelessWidget {
  final double size;
  const _Body({required this.size});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadProgressCubit, DownloadProgressViewState>(
      builder: (context, view) {
        switch (view.status) {
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
                tween: Tween(begin: 0, end: view.progress.clamp(0.0, 1.0)),
                builder: (_, value, _) => CircularProgressIndicator(
                  value: value > 0 ? value : null,
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent,
                  ),
                ),
              ),
            );
          case DownloadState.downloaded:
            return Icon(
              Icons.check_circle_rounded,
              size: size,
              color: AppColors.accent,
            );
          case DownloadState.failed:
            return Icon(
              Icons.error_outline_rounded,
              size: size,
              color: AppColors.error,
            );
          case DownloadState.notDownloaded:
          case DownloadState.cancelled:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
