import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/connection/widgets/connecting_screen.dart';
import '../../features/connection/widgets/server_setup_screen.dart';
import '../../features/library/data/models/album.dart';
import '../../features/library/widgets/album_detail_screen.dart';
import '../../features/library/widgets/artist_albums_screen.dart';
import '../../features/library/widgets/folder_tracks_screen.dart';
import '../../features/offline/widgets/downloaded_album_detail_screen.dart';
import '../../features/offline/widgets/downloaded_albums_screen.dart';
import 'root_screen.dart';

part 'app_router.gr.dart';

/// Phase 9 wiring. The root swaps between login and the bottom-tab shell
/// based on [SessionState] inside [RootScreen]; auto_route owns navigation
/// for everything underneath. Deep links to e.g. /album-detail land
/// directly when authenticated (Phase 11 will harden the unauthenticated
/// case with a redirect to /server-setup).
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/', page: RootRoute.page, initial: true),
    AutoRoute(path: '/server-setup', page: ServerSetupRoute.page),
    AutoRoute(path: '/connecting', page: ConnectingRoute.page),
    AutoRoute(path: '/artist-albums', page: ArtistAlbumsRoute.page),
    AutoRoute(path: '/album-detail', page: AlbumDetailRoute.page),
    AutoRoute(path: '/folder-tracks', page: FolderTracksRoute.page),
    AutoRoute(path: '/downloaded-albums', page: DownloadedAlbumsRoute.page),
    AutoRoute(
      path: '/downloaded-album-detail',
      page: DownloadedAlbumDetailRoute.page,
    ),
  ];
}

@RoutePage(name: 'RootRoute')
class RootRoutePage extends StatelessWidget {
  const RootRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const RootScreen();
}
