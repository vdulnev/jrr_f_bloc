import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/browse_navigation_cubit.dart';
import '../data/models/browse_item.dart';
import 'browse_breadcrumb.dart';
import 'browse_content.dart';

class BrowseTab extends StatelessWidget {
  const BrowseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BrowseNavigationCubit(scope: BrowseScope.browse),
      child: const _BrowseScaffold(),
    );
  }
}

class _BrowseScaffold extends StatelessWidget {
  const _BrowseScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseNavigationCubit, List<BrowseItem>>(
      builder: (context, stack) {
        if (stack.isEmpty) {
          // Should never happen for the browse scope — its initial state
          // includes the root crumb.
          return const SizedBox.shrink();
        }
        final current = stack.last;
        return PopScope(
          canPop: stack.length <= 1,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && stack.length > 1) {
              context.read<BrowseNavigationCubit>().pop();
            }
          },
          child: Column(
            children: [
              BrowseBreadcrumb(
                stack: stack,
                onTap: (i) =>
                    context.read<BrowseNavigationCubit>().navigateToBreadcrumb(i),
              ),
              Expanded(
                child: BrowseContent(key: ValueKey(current.id), current: current),
              ),
            ],
          ),
        );
      },
    );
  }
}
