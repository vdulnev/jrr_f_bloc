import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/artists_cubit.dart';
import '../bloc/random_albums_cubit.dart';
import '../bloc/search_bloc.dart';
import '../data/repositories/library_repository.dart';
import 'artists_tab.dart';
import 'browse_tab.dart';
import 'downloads_tab.dart';
import 'favorites_tab.dart';
import 'random_tab.dart';
import 'search_tab.dart';

/// Phase 7: a simple in-process tab switcher. Phase 9 will swap this for
/// AutoTabsRouter so deep links and route guards work.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  static const _tabs = [
    'Artists',
    'Random',
    'Browse',
    'Search',
    'Favorites',
    'Downloads',
  ];

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _active = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ArtistsCubit(repository: getIt<LibraryRepository>()),
        ),
        BlocProvider(
          create: (_) =>
              RandomAlbumsCubit(repository: getIt<LibraryRepository>()),
        ),
        BlocProvider(
          create: (_) =>
              SearchBloc(repository: getIt<LibraryRepository>()),
        ),
      ],
      child: Scaffold(
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
                    const Text('LIBRARY', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 6),
                    const Text('Browse', style: AppTextStyles.screenTitle),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          for (var i = 0; i < LibraryScreen._tabs.length; i++)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _active = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _active == i
                                        ? AppColors.bg4
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    LibraryScreen._tabs[i],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: _active == i
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
                  index: _active,
                  children: const [
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
      ),
    );
  }
}
