import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../bloc/browse_children_cubit.dart';
import '../bloc/browse_navigation_cubit.dart';
import '../bloc/library_async_state.dart';
import '../data/models/browse_item.dart';
import '../data/repositories/library_repository.dart';
import 'browse_files_screen.dart';
import 'browse_item_tile.dart';

/// Lists the children of the current breadcrumb node. Tapping a child
/// either descends (push to nav stack) or — if the child is a leaf with
/// no children of its own — navigates to a track list screen.
class BrowseContent extends StatelessWidget {
  final BrowseItem current;

  const BrowseContent({required this.current, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(current.id),
      create: (_) => BrowseChildrenCubit(
        id: current.id,
        repository: getIt<LibraryRepository>(),
      ),
      child: BlocBuilder<BrowseChildrenCubit, LibAsync<List<BrowseItem>>>(
        builder: (context, state) => switch (state) {
          LibLoading<List<BrowseItem>>() => const LoadingView(),
          LibError<List<BrowseItem>>(:final error) => ErrorView(
            error: error,
            onRetry: () => context.read<BrowseChildrenCubit>().load(),
          ),
          LibData<List<BrowseItem>>(:final value) =>
            value.isEmpty
                // No children — treat current node as a leaf and render its
                // files.
                ? BrowseFilesScreen(id: current.id, name: current.name)
                : _Children(items: value, parent: current),
        },
      ),
    );
  }
}

class _Children extends StatelessWidget {
  final List<BrowseItem> items;
  final BrowseItem parent;

  const _Children({required this.items, required this.parent});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<BrowseNavigationCubit>();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return BrowseItemTile(item: item, onTap: () => nav.push(item));
      },
    );
  }
}
