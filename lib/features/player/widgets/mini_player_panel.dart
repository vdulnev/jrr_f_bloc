import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/artwork_widget.dart';
import '../../../shared/widgets/transport_button.dart';
import '../../../shared/widgets/volume_slider.dart';
import '../bloc/player_controller_cubit.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import '../data/models/playback_state.dart';
import '../data/models/player_status.dart';

class MiniPlayerPanel extends StatelessWidget {
  final VoidCallback? onItemTap;

  const MiniPlayerPanel({this.onItemTap, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerSnapshot>(
      builder: (context, snap) {
        final status = switch (snap) {
          PlayerData(:final status) => status,
          _ => null,
        };
        return _Body(status: status, onItemTap: onItemTap);
      },
    );
  }
}

class _Body extends StatelessWidget {
  final PlayerStatus? status;
  final VoidCallback? onItemTap;

  const _Body({required this.status, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<PlayerControllerCubit>();
    final hasTracks = (status?.playingNowTracks ?? 0) > 0;
    final positionMs = status?.positionMs ?? 0;
    final durationMs = status?.durationMs ?? 0;
    final progress = durationMs > 0
        ? (positionMs / durationMs).clamp(0.0, 1.0)
        : 0.0;
    final name = status?.name.isNotEmpty == true ? status!.name : 'Unknown Track';
    final artist =
        status?.artist.isNotEmpty == true ? status!.artist : 'Unknown Artist';
    final isPlaying = status?.state == PlaybackState.playing;

    return GestureDetector(
      onTap: onItemTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 2,
              child: Stack(
                children: [
                  Container(color: AppColors.bg4),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: ArtworkWidget(fileKey: status?.fileKey, size: 40),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              artist,
                              style: AppTextStyles.itemSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TransportButton(
                            size: 36,
                            onPressed: hasTracks ? controller.previous : null,
                            child: const Icon(
                              Icons.skip_previous_rounded,
                              size: 20,
                            ),
                          ),
                          TransportButton(
                            size: 36,
                            onPressed: hasTracks ? controller.playPause : null,
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 20,
                            ),
                          ),
                          TransportButton(
                            size: 36,
                            onPressed: hasTracks ? controller.next : null,
                            child: const Icon(
                              Icons.skip_next_rounded,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  VolumeSlider(
                    value: status?.volume ?? 1.0,
                    isMuted: status?.isMuted ?? false,
                    onChanged: controller.setVolume,
                    onMuteToggle: controller.toggleMute,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
