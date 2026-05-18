import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../player/player_command_service.dart';
import '../data/models/tracks.dart';

Future<void> showLibraryActionSheet(
  BuildContext context, {
  required Tracks tracks,
  String? title,
}) async {
  final commands = getIt<PlayerCommandService>();
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetCtx) =>
        _LibraryActionSheet(title: title, tracks: tracks, commands: commands),
  );
  await commands.refresh();
}

class _LibraryActionSheet extends StatelessWidget {
  final PlayerCommandService commands;
  final String? title;
  final Tracks tracks;

  const _LibraryActionSheet({
    required this.commands,
    this.title,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Play now'),
            onTap: () {
              commands.playNow(tracks);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_play_next),
            title: const Text('Play next'),
            onTap: () {
              commands.playNext(tracks);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_to_queue),
            title: const Text('Add to queue'),
            onTap: () {
              commands.addToQueue(tracks);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
