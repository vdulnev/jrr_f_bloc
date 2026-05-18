import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/artwork_widget.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/transport_button.dart';
import '../../../shared/widgets/volume_slider.dart';
import '../../library/data/models/track.dart';
import '../../library/track_lookup_service.dart';
import '../../zones/active_zone_service.dart';
import '../../zones/data/models/zone.dart';
import '../bloc/now_playing_cubit.dart';
import '../bloc/now_playing_state.dart';
import '../data/models/playback_state.dart';
import '../data/models/player_status.dart';
import '../data/models/repeat_mode.dart';
import '../data/models/shuffle_mode.dart';
import '../player_command_service.dart';
import '../player_service.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NowPlayingCubit>(
      create: (_) => NowPlayingCubit(
        activeZone: getIt<ActiveZoneService>(),
        player: getIt<PlayerService>(),
        lookup: getIt<TrackLookupService>(),
        commands: getIt<PlayerCommandService>(),
      ),
      child: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Scaffold(body: LoadingView()),
            data: (d) {
              final fileKey = d.status?.fileKey ?? -1;
              if (fileKey < 0) {
                return _EmptyState(zone: d.zone, status: d.status);
              }
              return _NowPlayingBody(
                zone: d.zone,
                status: d.status!,
                track: d.track,
              );
            },
          );
        },
      ),
    );
  }
}

class _NowPlayingBody extends StatelessWidget {
  final Zone zone;
  final PlayerStatus status;
  final Track? track;

  const _NowPlayingBody({
    required this.zone,
    required this.status,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NowPlayingCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOW PLAYING',
                          style: AppTextStyles.sectionLabel,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatHeader(zone.name, status, track),
                          style: AppTextStyles.itemSubtitle,
                        ),
                      ],
                    ),
                  ),
                  if (status.playingNowTracks > 0)
                    Text(
                      '${status.playingNowPosition + 1} / ${status.playingNowTracks}',
                      style: AppTextStyles.monoLabel,
                    ),
                ],
              ),
            ),

            // Artwork
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                        maxHeight: 280,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCC000000),
                            blurRadius: 60,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ArtworkWidget(fileKey: status.fileKey, size: 280),
                    ),
                  ),
                ),
              ),
            ),

            // Track info + controls
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.name.isNotEmpty
                              ? status.name
                              : 'Nothing playing',
                          style: AppTextStyles.nowPlayingTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          status.artist,
                          style: AppTextStyles.nowPlayingArtist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status.album,
                          style: AppTextStyles.monoLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProgressSection(status: status, cubit: cubit),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TransportButton(
                        size: 40,
                        color: status.shuffleMode != ShuffleMode.off
                            ? AppColors.accent
                            : AppColors.text3,
                        onPressed: cubit.toggleShuffle,
                        child: const Icon(Icons.shuffle, size: 18),
                      ),
                      TransportButton(
                        size: 44,
                        onPressed: cubit.previous,
                        child: const Icon(
                          Icons.skip_previous_rounded,
                          size: 28,
                        ),
                      ),
                      TransportButton(
                        size: 60,
                        accent: true,
                        onPressed: cubit.playPause,
                        child: Icon(
                          status.state == PlaybackState.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                        ),
                      ),
                      TransportButton(
                        size: 44,
                        onPressed: cubit.next,
                        child: const Icon(Icons.skip_next_rounded, size: 28),
                      ),
                      TransportButton(
                        size: 40,
                        color: status.repeatMode != RepeatMode.off
                            ? AppColors.accent
                            : AppColors.text3,
                        onPressed: cubit.cycleRepeat,
                        child: const Icon(Icons.repeat, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  VolumeSlider(
                    value: status.volume,
                    isMuted: status.isMuted,
                    onChanged: cubit.setVolume,
                    onMuteToggle: cubit.toggleMute,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatHeader(String zoneName, PlayerStatus s, Track? track) {
    final fileType = track?.fileType ?? '';
    if (s.bitDepth > 0 && s.sampleRate > 0) {
      final sr = s.sampleRate >= 1000
          ? '${(s.sampleRate / 1000).round()}'
          : '${s.sampleRate}';
      final prefix = fileType.isNotEmpty ? '$fileType ' : '';
      return '$zoneName · $prefix${s.bitDepth}/$sr';
    }
    return zoneName;
  }
}

class _ProgressSection extends StatelessWidget {
  final PlayerStatus status;
  final NowPlayingCubit cubit;

  const _ProgressSection({required this.status, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final positionMs = status.positionMs;
    final durationMs = status.durationMs;
    final progress = durationMs > 0
        ? (positionMs / durationMs).clamp(0.0, 1.0)
        : 0.0;
    final elapsed = positionMs ~/ 1000;
    final remaining = durationMs > 0 ? (durationMs - positionMs) ~/ 1000 : 0;

    return Column(
      children: [
        AppProgressBar(
          progress: progress,
          onChanged: (v) {
            final ms = (v * durationMs).round();
            cubit.seekTo(ms);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(elapsed), style: AppTextStyles.monoLabel),
              Text('-${_fmt(remaining)}', style: AppTextStyles.monoLabel),
            ],
          ),
        ),
      ],
    );
  }

  static String _fmt(int seconds) {
    if (seconds < 0) seconds = 0;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  final Zone zone;
  final PlayerStatus? status;

  const _EmptyState({required this.zone, required this.status});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NowPlayingCubit>();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOW PLAYING', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 4),
                  Text(zone.name, style: AppTextStyles.itemSubtitle),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 64,
                    color: AppColors.text3.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nothing playing',
                    style: AppTextStyles.nowPlayingArtist,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a track from the library',
                    style: AppTextStyles.monoLabel.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: VolumeSlider(
              value: status?.volume ?? 0,
              isMuted: status?.isMuted ?? false,
              onChanged: cubit.setVolume,
              onMuteToggle: cubit.toggleMute,
            ),
          ),
        ],
      ),
    );
  }
}
