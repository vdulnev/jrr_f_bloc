import 'package:flutter/material.dart';

import '../data/models/album_group.dart';
import 'album_row_tile.dart';

/// Renders a list of [AlbumGroup]s with expandable multi-disc rows.
/// Owns its own [CustomScrollView] so any chrome that should scroll with
/// the list (a Refresh button, a filter field, etc.) can be passed in
/// via [leadingSlivers].
class AlbumListView extends StatefulWidget {
  final List<AlbumGroup> groups;
  final bool showArtist;
  final List<Widget> leadingSlivers;

  const AlbumListView({
    required this.groups,
    this.showArtist = true,
    this.leadingSlivers = const [],
    super.key,
  });

  @override
  State<AlbumListView> createState() => _AlbumListViewState();
}

class _AlbumListViewState extends State<AlbumListView> {
  final Set<String> _expanded = {};

  String _keyFor(AlbumGroup g) =>
      '${g.album.name.toLowerCase()}|${g.album.folderPath.toLowerCase()}';

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ...widget.leadingSlivers,
        SliverList.builder(
          itemCount: widget.groups.length,
          itemBuilder: (_, i) {
            final group = widget.groups[i];
            if (!group.isMultiDisc) {
              return AlbumRowTile(
                album: group.album,
                showArtist: widget.showArtist,
              );
            }
            final key = _keyFor(group);
            final expanded = _expanded.contains(key);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AlbumRowTile(
                  album: group.album,
                  showArtist: widget.showArtist,
                  hasSubItems: true,
                  isExpanded: expanded,
                  onToggle: () => setState(() {
                    if (expanded) {
                      _expanded.remove(key);
                    } else {
                      _expanded.add(key);
                    }
                  }),
                ),
                if (expanded)
                  for (final disc in group.discs)
                    AlbumRowTile(
                      album: disc,
                      showArtist: false,
                      indent: 28,
                      titleOverride:
                          'Disc ${disc.discNumber}/${disc.totalDiscs}',
                    ),
              ],
            );
          },
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}
