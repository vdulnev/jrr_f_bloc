import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../features/library/data/models/tracks.dart';
import '../../features/player/bloc/player_controller_cubit.dart';

/// Compact popup menu for a track or group of tracks. Phase 7 ships
/// Play / Play next / Add to playing now; Phase 8 layers in the
/// Download / Cancel / Delete entries.
class TracksPopupMenu extends StatelessWidget {
  final Tracks tracks;
  final String? label;

  const TracksPopupMenu({required this.tracks, this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.text3),
      padding: EdgeInsets.zero,
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'play',
          child: ListTile(
            leading: Icon(Icons.play_arrow_outlined),
            title: Text('Play'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem(
          value: 'playNext',
          child: ListTile(
            leading: Icon(Icons.queue_play_next),
            title: Text('Play next'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem(
          value: 'add',
          child: ListTile(
            leading: Icon(Icons.add_circle_outline),
            title: Text('Add to playing now'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, String action) {
    final controller = context.read<PlayerControllerCubit>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    switch (action) {
      case 'play':
        controller.playNow(tracks);
      case 'playNext':
        controller.playNext(tracks);
      case 'add':
        controller.addToQueue(tracks);
        if (label != null) {
          messenger?.showSnackBar(
            SnackBar(
              content: Text('Added "$label" to playing now'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
    }
    controller.refresh();
  }
}
