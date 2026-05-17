import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../player/bloc/player_controller_cubit.dart';
import '../data/models/tracks.dart';

Future<void> showLibraryActionSheet(
  BuildContext context, {
  required Tracks tracks,
  String? title,
}) async {
  final controller = context.read<PlayerControllerCubit>();
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetCtx) => _LibraryActionSheet(
      title: title,
      tracks: tracks,
      controller: controller,
    ),
  );
  await controller.refresh();
}

class _LibraryActionSheet extends StatelessWidget {
  final PlayerControllerCubit controller;
  final String? title;
  final Tracks tracks;

  const _LibraryActionSheet({
    required this.controller,
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
              controller.playNow(tracks);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_play_next),
            title: const Text('Play next'),
            onTap: () {
              controller.playNext(tracks);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_to_queue),
            title: const Text('Add to queue'),
            onTap: () {
              controller.addToQueue(tracks);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
