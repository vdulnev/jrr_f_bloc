import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../favorites/bloc/favorites_tab_cubit.dart';
import '../../favorites/favorites_service.dart';
import '../bloc/browse_navigation_cubit.dart';
import '../data/models/browse_item.dart';
import 'browse_breadcrumb.dart';
import 'browse_content.dart';
import 'browse_item_tile.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BrowseNavigationCubit(scope: BrowseScope.favorites),
        ),
        BlocProvider(
          create: (_) =>
              FavoritesTabCubit(service: getIt<FavoritesService>()),
        ),
      ],
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseNavigationCubit, List<BrowseItem>>(
      builder: (context, stack) {
        if (stack.isEmpty) {
          return BlocBuilder<FavoritesTabCubit, List<BrowseItem>>(
            builder: (context, favorites) {
              if (favorites.isEmpty) return const _EmptyState();
              return CustomScrollView(
                slivers: [
                  SliverList.builder(
                    itemCount: favorites.length,
                    itemBuilder: (_, i) {
                      final item = favorites[i];
                      return BrowseItemTile(
                        item: item,
                        showFavoriteToggle: true,
                        onTap: () =>
                            context.read<BrowseNavigationCubit>().push(item),
                      );
                    },
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                ],
              );
            },
          );
        }

        final current = stack.last;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<BrowseNavigationCubit>().pop();
          },
          child: Column(
            children: [
              BrowseBreadcrumb(
                stack: stack,
                prefix: 'Favorites',
                onTap: (i) => context
                    .read<BrowseNavigationCubit>()
                    .navigateToBreadcrumb(i),
              ),
              Expanded(
                child: BrowseContent(
                  key: ValueKey(current.id),
                  current: current,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_outlined,
            size: 64,
            color: AppColors.text3,
          ),
          SizedBox(height: 16),
          Text('No favorites yet', style: AppTextStyles.emptyState),
          SizedBox(height: 8),
          Text(
            'Browse folders and tap the heart icon to add them here',
            style: AppTextStyles.itemSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
