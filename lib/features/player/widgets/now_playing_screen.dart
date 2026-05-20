import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/artwork_widget.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/transport_button.dart';
import '../../../shared/widgets/volume_slider.dart';
import '../../library/track_lookup_service.dart';
import '../../zones/active_zone_service.dart';
import '../bloc/now_playing_cubit.dart';
import '../bloc/now_playing_state.dart';
import '../data/models/playback_state.dart';
import '../data/models/player_status.dart';
import '../data/models/repeat_mode.dart';
import '../data/models/shuffle_mode.dart';
import '../player_command_service.dart';
import '../player_service.dart';

void _log(String widget) =>
    getIt<Talker>().debug('[NowPlayingScreen] build $widget');

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _log('NowPlayingScreen');
    return BlocProvider<NowPlayingCubit>(
      create: (_) => NowPlayingCubit(
        activeZone: getIt<ActiveZoneService>(),
        player: getIt<PlayerService>(),
        lookup: getIt<TrackLookupService>(),
        commands: getIt<PlayerCommandService>(),
      ),
      child: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        buildWhen: (prev, next) => _shellFor(prev) != _shellFor(next),
        builder: (context, state) => switch (_shellFor(state)) {
          _Shell.loading => const Scaffold(body: LoadingView()),
          _Shell.empty => _EmptyState(state: state as NowPlayingData),
          _Shell.playing => const _NowPlayingBody(),
        },
      ),
    );
  }
}

enum _Shell { loading, empty, playing }

_Shell _shellFor(NowPlayingState s) => switch (s) {
  NowPlayingLoading() => _Shell.loading,
  NowPlayingData(:final status) =>
    (status == null || status.fileKey < 0) ? _Shell.empty : _Shell.playing,
};

PlayerStatus? _statusOf(NowPlayingState s) => switch (s) {
  NowPlayingData(:final status) => status,
  _ => null,
};

class _NowPlayingBody extends StatelessWidget {
  const _NowPlayingBody();

  @override
  Widget build(BuildContext context) {
    _log('_NowPlayingBody');
    return const Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _HeaderSection(),
            ),
            Expanded(child: _ArtworkSection()),
            Padding(
              padding: EdgeInsets.only(top: 16, left: 24, right: 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _TrackInfoSection(),
                  ),
                  SizedBox(height: 16),
                  _ProgressSection(),
                  SizedBox(height: 20),
                  _TransportSection(),
                  SizedBox(height: 16),
                  _VolumeSection(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _HeaderVm = ({
  String zoneName,
  String fileType,
  int bitDepth,
  int sampleRate,
  int posInQueue,
  int queueLen,
});

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NowPlayingCubit, NowPlayingState, _HeaderVm>(
      selector: (s) => switch (s) {
        NowPlayingData(:final zone, :final status, :final track) => (
          zoneName: zone.name,
          fileType: track?.fileType ?? '',
          bitDepth: status?.bitDepth ?? 0,
          sampleRate: status?.sampleRate ?? 0,
          posInQueue: status?.playingNowPosition ?? 0,
          queueLen: status?.playingNowTracks ?? 0,
        ),
        _ => (
          zoneName: '',
          fileType: '',
          bitDepth: 0,
          sampleRate: 0,
          posInQueue: 0,
          queueLen: 0,
        ),
      },
      builder: (_, vm) {
        _log('_HeaderSection');
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOW PLAYING', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 4),
                  Text(_formatHeader(vm), style: AppTextStyles.itemSubtitle),
                ],
              ),
            ),
            if (vm.queueLen > 0)
              Text(
                '${vm.posInQueue + 1} / ${vm.queueLen}',
                style: AppTextStyles.monoLabel,
              ),
          ],
        );
      },
    );
  }

  static String _formatHeader(_HeaderVm vm) {
    if (vm.bitDepth > 0 && vm.sampleRate > 0) {
      final sr = vm.sampleRate >= 1000
          ? '${(vm.sampleRate / 1000).round()}'
          : '${vm.sampleRate}';
      final prefix = vm.fileType.isNotEmpty ? '${vm.fileType} ' : '';
      return '${vm.zoneName} · $prefix${vm.bitDepth}/$sr';
    }
    return vm.zoneName;
  }
}

class _ArtworkSection extends StatelessWidget {
  const _ArtworkSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NowPlayingCubit, NowPlayingState, int>(
      selector: (s) => _statusOf(s)?.fileKey ?? -1,
      builder: (_, fileKey) {
        _log('_ArtworkSection');
        return Center(
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
                child: ArtworkWidget(fileKey: fileKey, size: 280),
              ),
            ),
          ),
        );
      },
    );
  }
}

typedef _TrackInfoVm = ({String name, String artist, String album});

class _TrackInfoSection extends StatelessWidget {
  const _TrackInfoSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NowPlayingCubit, NowPlayingState, _TrackInfoVm>(
      selector: (s) {
        final st = _statusOf(s);
        return (
          name: st?.name ?? '',
          artist: st?.artist ?? '',
          album: st?.album ?? '',
        );
      },
      builder: (_, vm) {
        _log('_TrackInfoSection');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vm.name.isNotEmpty ? vm.name : 'Nothing playing',
              style: AppTextStyles.nowPlayingTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              vm.artist,
              style: AppTextStyles.nowPlayingArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              vm.album,
              style: AppTextStyles.monoLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}

typedef _ProgressVm = ({int positionMs, int durationMs});

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NowPlayingCubit, NowPlayingState, _ProgressVm>(
      selector: (s) {
        final st = _statusOf(s);
        return (
          positionMs: st?.positionMs ?? 0,
          durationMs: st?.durationMs ?? 0,
        );
      },
      builder: (context, vm) {
        final cubit = context.read<NowPlayingCubit>();
        final progress = vm.durationMs > 0
            ? (vm.positionMs / vm.durationMs).clamp(0.0, 1.0)
            : 0.0;
        final elapsed = vm.positionMs ~/ 1000;
        final remaining = vm.durationMs > 0
            ? (vm.durationMs - vm.positionMs) ~/ 1000
            : 0;

        _log('_ProgressSection');
        return Column(
          children: [
            AppProgressBar(
              progress: progress,
              onChanged: (v) => cubit.seekTo((v * vm.durationMs).round()),
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
      },
    );
  }

  static String _fmt(int seconds) {
    if (seconds < 0) seconds = 0;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

typedef _TransportVm = ({
  PlaybackState state,
  ShuffleMode shuffleMode,
  RepeatMode repeatMode,
});

class _TransportSection extends StatelessWidget {
  const _TransportSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NowPlayingCubit, NowPlayingState, _TransportVm>(
      selector: (s) {
        final st = _statusOf(s);
        return (
          state: st?.state ?? PlaybackState.stopped,
          shuffleMode: st?.shuffleMode ?? ShuffleMode.off,
          repeatMode: st?.repeatMode ?? RepeatMode.off,
        );
      },
      builder: (context, vm) {
        _log('_TransportSection');
        final cubit = context.read<NowPlayingCubit>();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TransportButton(
              size: 40,
              color: vm.shuffleMode != ShuffleMode.off
                  ? AppColors.accent
                  : AppColors.text3,
              onPressed: cubit.toggleShuffle,
              child: const Icon(Icons.shuffle, size: 18),
            ),
            TransportButton(
              size: 44,
              onPressed: cubit.previous,
              child: const Icon(Icons.skip_previous_rounded, size: 28),
            ),
            TransportButton(
              size: 60,
              accent: true,
              onPressed: cubit.playPause,
              child: Icon(
                vm.state == PlaybackState.playing
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
              color: vm.repeatMode != RepeatMode.off
                  ? AppColors.accent
                  : AppColors.text3,
              onPressed: cubit.cycleRepeat,
              child: const Icon(Icons.repeat, size: 18),
            ),
          ],
        );
      },
    );
  }
}

typedef _VolumeVm = ({double volume, bool isMuted});

class _VolumeSection extends StatelessWidget {
  const _VolumeSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NowPlayingCubit, NowPlayingState, _VolumeVm>(
      selector: (s) {
        final st = _statusOf(s);
        return (volume: st?.volume ?? 0, isMuted: st?.isMuted ?? false);
      },
      builder: (context, vm) {
        _log('_VolumeSection');
        final cubit = context.read<NowPlayingCubit>();
        return VolumeSlider(
          value: vm.volume,
          isMuted: vm.isMuted,
          onChanged: cubit.setVolume,
          onMuteToggle: cubit.toggleMute,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final NowPlayingData state;

  const _EmptyState({required this.state});

  @override
  Widget build(BuildContext context) {
    _log('_EmptyState');
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
                  Text(state.zone.name, style: AppTextStyles.itemSubtitle),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: _VolumeSection(),
          ),
        ],
      ),
    );
  }
}
