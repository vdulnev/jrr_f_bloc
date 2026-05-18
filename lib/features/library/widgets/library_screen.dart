import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../zones/active_zone_service.dart';
import '../bloc/artists_cubit.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import '../bloc/random_albums_cubit.dart';
import '../bloc/search_bloc.dart';
import '../data/repositories/library_repository.dart';
import 'artists_tab.dart';
import 'browse_tab.dart';
import 'downloads_tab.dart';
import 'favorites_tab.dart';
import 'random_tab.dart';
import 'search_tab.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  /// Online tabs and the always-available local-content tab.
  static const _allTabs = [
    'Artists',
    'Random',
    'Browse',
    'Search',
    'Favorites',
    'Downloads',
  ];

  /// Offline mode disables every server-bound tab; only Downloads remains.
  static const _offlineTabs = ['Downloads'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryCubit>(
      create: (_) => LibraryCubit(activeZone: getIt<ActiveZoneService>()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ArtistsCubit(repository: getIt<LibraryRepository>()),
          ),
          BlocProvider(
            create: (_) =>
                RandomAlbumsCubit(repository: getIt<LibraryRepository>()),
          ),
          BlocProvider(
            create: (_) => SearchBloc(repository: getIt<LibraryRepository>()),
          ),
        ],
        child: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            final tabs = state.isOffline
                ? LibraryScreen._offlineTabs
                : LibraryScreen._allTabs;
            final activeIndex = state.activeTabIndex;

            return Scaffold(
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LIBRARY',
                            style: AppTextStyles.sectionLabel,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.isOffline ? 'Offline' : 'Browse',
                            style: AppTextStyles.screenTitle,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.bg2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                for (var i = 0; i < tabs.length; i++)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => context
                                          .read<LibraryCubit>()
                                          .setActiveTab(i),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: activeIndex == i
                                              ? AppColors.bg4
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          tabs[i],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: activeIndex == i
                                                    ? AppColors.text
                                                    : AppColors.text3,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: activeIndex,
                        children: state.isOffline
                            ? const [DownloadsTab()]
                            : const [
                                ArtistsTab(),
                                RandomTab(),
                                BrowseTab(),
                                SearchTab(),
                                FavoritesTab(),
                                DownloadsTab(),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
