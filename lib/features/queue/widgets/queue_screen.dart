import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/vu_meter.dart';
import '../../library/data/models/track.dart';
import '../../library/data/models/tracks.dart';
import '../../player/bloc/player_controller_cubit.dart';
import '../bloc/queue_cubit.dart';
import '../bloc/queue_state.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<QueueCubit, QueueState>(
          builder: (context, state) => switch (state) {
            QueueLoading() => const LoadingView(),
            QueueError(:final error) => ErrorView(
              error: error,
              onRetry: () => context.read<QueueCubit>().refresh(),
            ),
            QueueLoaded(:final tracks) when tracks.isEmpty => _EmptyView(
              tracks: tracks,
              onClearTap: () => _confirmClear(context),
            ),
            QueueLoaded(:final tracks, :final currentIndex) => _DataView(
                  items: tracks,
                  currentIndex: currentIndex,
                  onTap: (i) =>
                      context.read<PlayerControllerCubit>().playByIndex(i),
                  onRemove: (i) => context.read<QueueCubit>().removeItem(i),
                  onClearTap: () => _confirmClear(context),
                ),
          },
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<QueueCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: const Text('Clear queue?', style: AppTextStyles.subScreenTitle),
        content: const Text(
          'This will remove all tracks from the playing now queue.',
          style: AppTextStyles.itemSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.clearQueue();
  }
}

class _DataView extends StatelessWidget {
  const _DataView({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.onRemove,
    required this.onClearTap,
  });

  final Tracks items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onRemove;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(tracks: items, onClearTap: onClearTap),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('UP NEXT', style: AppTextStyles.sectionHeading),
          ),
        ),
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final track = items[i];
            return _Track(
              key: ValueKey('${track.fileKey}_$i'),
              track: track,
              isCurrent: i == currentIndex,
              onTap: () => onTap(i),
              onDismissed: () => onRemove(i),
              index: i,
            );
          },
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.tracks, required this.onClearTap});

  final Tracks tracks;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(tracks: tracks, onClearTap: onClearTap),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('UP NEXT', style: AppTextStyles.sectionHeading),
          ),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text('Queue is empty', style: AppTextStyles.emptyState),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tracks, required this.onClearTap});

  final Tracks tracks;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PLAYBACK', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Queue', style: AppTextStyles.screenTitle),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${tracks.length} tracks',
                    style: AppTextStyles.monoLabel,
                  ),
                  if (tracks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onClearTap,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_sweep_outlined,
                              size: 16,
                              color: AppColors.text2,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'CLEAR',
                              style: TextStyle(
                                fontFamily: AppFonts.mono,
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: AppColors.text2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Track extends StatelessWidget {
  final Track track;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onDismissed;
  final int index;

  const _Track({
    required this.track,
    required this.isCurrent,
    required this.onTap,
    required this.onDismissed,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_${track.fileKey}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error.withValues(alpha: 0.18),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 20,
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.accentDim : Colors.transparent,
            border: const Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Stack(
            children: [
              if (isCurrent)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2.5,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(left: isCurrent ? 8 : 0),
                child: Row(
                  children: [
                    if (isCurrent)
                      const VUMeter(active: true)
                    else
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.monoLabel,
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: AppTextStyles.itemTitle.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            [
                              track.artist,
                              track.album,
                            ].where((s) => s.isNotEmpty).join(' · '),
                            style: AppTextStyles.itemSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDuration(track.duration),
                      style: AppTextStyles.monoLabel,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.drag_handle,
                      size: 16,
                      color: AppColors.text3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final total = seconds.round();
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
