import 'package:flutter/material.dart';

import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/sub_screen_header.dart';
import '../../../shared/widgets/tracks_popup_menu.dart';
import '../bloc/library_async_state.dart';
import '../data/models/tracks.dart';
import 'library_item_tile.dart';
import 'multi_disc_list.dart';

/// Shared chrome for the album / folder / browse-files track lists.
/// Takes the typed [LibAsync<Tracks>] state from a feature cubit.
class TrackListScaffold extends StatelessWidget {
  final Widget title;
  final String? subtitle;
  final LibAsync<Tracks> tracksState;
  final VoidCallback onRetry;
  final String actionSheetTitle;
  final String addedSnackbarLabel;
  final Widget? headerContent;
  final VoidCallback? onBack;
  final Widget? emptyState;

  const TrackListScaffold({
    required this.title,
    this.subtitle,
    required this.tracksState,
    required this.onRetry,
    required this.actionSheetTitle,
    required this.addedSnackbarLabel,
    this.headerContent,
    this.onBack,
    this.emptyState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubScreenHeader(
              titleWidget: title,
              subtitle: subtitle,
              onBack: onBack ?? () => Navigator.of(context).maybePop(),
              content: headerContent,
              trailing: switch (tracksState) {
                LibData<Tracks>(:final value) when value.isNotEmpty =>
                  TracksPopupMenu(tracks: value, label: addedSnackbarLabel),
                _ => null,
              },
            ),
            Expanded(
              child: switch (tracksState) {
                LibLoading<Tracks>() => const LoadingView(),
                LibError<Tracks>(:final error) =>
                  ErrorView(error: error, onRetry: onRetry),
                LibData<Tracks>(:final value) => value.isEmpty
                    ? (emptyState ??
                        const Center(child: Text('No tracks found')))
                    : _ContentList(tracks: value),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentList extends StatelessWidget {
  final Tracks tracks;
  const _ContentList({required this.tracks});

  @override
  Widget build(BuildContext context) {
    final isMultiDisc =
        tracks.tracks.any((t) => t.totalDiscs > 1 || t.discNumber > 1);
    return CustomScrollView(
      slivers: [
        if (isMultiDisc)
          MultiDiscSliverList(tracks: tracks.tracks)
        else
          SliverList.builder(
            itemCount: tracks.length,
            itemBuilder: (_, i) => LibraryItemTile(
              item: tracks[i],
              trackNumber:
                  tracks[i].trackNumber > 0 ? tracks[i].trackNumber : i + 1,
              collapsedByDefault: true,
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}
