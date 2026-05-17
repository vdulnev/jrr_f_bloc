import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../bloc/library_async_state.dart';
import '../bloc/search_bloc.dart';
import '../data/models/tracks.dart';
import 'library_item_tile.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search tracks, artists, albums…',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        context.read<SearchBloc>().add(
                          const SearchEvent.cleared(),
                        );
                        setState(() {});
                      },
                    ),
              isDense: true,
            ),
            style: AppTextStyles.labelLarge,
            onChanged: (v) {
              context.read<SearchBloc>().add(
                SearchEvent.queryChanged(query: v),
              );
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<SearchBloc, LibAsync<Tracks>>(
            builder: (context, state) => switch (state) {
              LibLoading<Tracks>() => const LoadingView(),
              LibError<Tracks>(:final error) => ErrorView(error: error),
              LibData<Tracks>(:final value) when value.isEmpty => Center(
                child: Text(
                  _controller.text.isEmpty
                      ? 'Type to search'
                      : 'No matches',
                  style: AppTextStyles.emptyState,
                ),
              ),
              LibData<Tracks>(:final value) => ListView.builder(
                itemCount: value.length,
                itemBuilder: (_, i) => LibraryItemTile(item: value[i]),
              ),
            },
          ),
        ),
      ],
    );
  }
}
