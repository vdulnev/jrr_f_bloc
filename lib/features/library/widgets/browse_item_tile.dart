import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../favorites/bloc/favorites_cubit.dart';
import '../data/models/browse_item.dart';

/// Single browse-tree row with optional favorite toggle on the trailing
/// edge. Watches [FavoritesCubit] so the heart updates live on toggle.
class BrowseItemTile extends StatelessWidget {
  final BrowseItem item;
  final VoidCallback onTap;
  final bool showFavoriteToggle;

  const BrowseItemTile({
    super.key,
    required this.item,
    required this.onTap,
    this.showFavoriteToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, List<BrowseItem>>(
      builder: (context, favorites) {
        final isFav = favorites.any((f) => f.id == item.id);
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bg3,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.folder_outlined,
                    size: 20,
                    color: AppColors.text3,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(item.name, style: AppTextStyles.itemTitle),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.text3,
                ),
                if (showFavoriteToggle) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.accent : AppColors.text3,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        context.read<FavoritesCubit>().toggle(item),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
