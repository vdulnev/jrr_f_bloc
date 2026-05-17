import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../player/bloc/player_controller_cubit.dart';
import '../data/models/track.dart';
import '../data/models/tracks.dart';

/// Track row used in album / folder / search lists. Tap to toggle path
/// details; the popup menu offers Play / Play next / Add to playing now.
/// Phase 8 will layer in the per-track Download / Cancel / Delete entries
/// and offline-aware visibility rules.
class LibraryItemTile extends StatefulWidget {
  final Track item;
  final int? trackNumber;
  final bool collapsedByDefault;

  const LibraryItemTile({
    required this.item,
    this.trackNumber,
    this.collapsedByDefault = false,
    super.key,
  });

  @override
  State<LibraryItemTile> createState() => _LibraryItemTileState();
}

class _LibraryItemTileState extends State<LibraryItemTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final displayTrackNumber =
        widget.trackNumber ?? (item.trackNumber > 0 ? item.trackNumber : null);
    return ListTile(
      leading: displayTrackNumber != null
          ? SizedBox(
              width: 32,
              child: Text(
                '$displayTrackNumber',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : null,
      title: Text(
        item.name.isNotEmpty ? item.name : 'Unknown',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              [
                item.dateReadable,
                item.album,
              ].where((s) => s.isNotEmpty).join(' - '),
              item.artist,
            ].where((s) => s.isNotEmpty).join(' · '),
            style: AppTextStyles.itemSubtitle,
          ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            Text(
              item.folderPath,
              style: AppTextStyles.monoLabel.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 2),
            Text(
              item.filePath,
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 10,
                color: AppColors.text3,
              ),
            ),
          ],
        ],
      ),
      onTap: () => setState(() => _expanded = !_expanded),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.text3),
        padding: EdgeInsets.zero,
        onSelected: (action) => _handleAction(context, action, item),
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
      ),
    );
  }

  void _handleAction(BuildContext context, String action, Track item) {
    final controller = context.read<PlayerControllerCubit>();
    final tracks = Tracks(tracks: [item]);
    switch (action) {
      case 'play':
        controller.playNow(tracks);
      case 'playNext':
        controller.playNext(tracks);
      case 'add':
        controller.addToQueue(tracks);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to playing now'),
            duration: Duration(seconds: 1),
          ),
        );
    }
  }
}
