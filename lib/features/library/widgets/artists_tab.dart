import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/scroll_chrome_listener.dart';
import '../bloc/artists_cubit.dart';
import '../bloc/library_async_state.dart';
import 'library_navigation.dart';

class ArtistsTab extends StatefulWidget {
  const ArtistsTab({super.key});

  @override
  State<ArtistsTab> createState() => _ArtistsTabState();
}

class _ArtistsTabState extends State<ArtistsTab> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistsCubit, LibAsync<List<String>>>(
      builder: (context, state) => switch (state) {
        LibLoading<List<String>>() => const LoadingView(),
        LibError<List<String>>(:final error) => ErrorView(
          error: error,
          onRetry: () => context.read<ArtistsCubit>().load(),
        ),
        LibData<List<String>>(:final value) => _List(
          artists: value,
          filter: _filter,
          onFilterChanged: (v) => setState(() => _filter = v),
          onRefresh: () => context.read<ArtistsCubit>().load(),
        ),
      },
    );
  }
}

class _List extends StatelessWidget {
  final List<String> artists;
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onRefresh;

  const _List({
    required this.artists,
    required this.filter,
    required this.onFilterChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = filter.isEmpty
        ? artists
        : artists
              .where((a) => a.toLowerCase().contains(filter.toLowerCase()))
              .toList();

    return ScrollChromeListener(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onRefresh,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.line2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Refresh',
                        style: AppTextStyles.accentSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Filter artists…',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                ),
                style: AppTextStyles.labelLarge,
                onChanged: onFilterChanged,
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('No matches', style: AppTextStyles.emptyState),
              ),
            )
          else
            SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final artist = filtered[i];
                return GestureDetector(
                  onTap: () => pushArtistAlbums(context, artist),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.line)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bg3,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            artist.isNotEmpty ? artist[0].toUpperCase() : '?',
                            style: AppTextStyles.avatarLetter,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(artist, style: AppTextStyles.itemTitle),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.text3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}
