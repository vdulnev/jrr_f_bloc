import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../core/router/app_router.dart';

void pushDownloadedAlbums(BuildContext context, String artist) {
  context.router.push(DownloadedAlbumsRoute(artist: artist));
}

void pushDownloadedAlbumDetail(BuildContext context, String albumGroupId) {
  context.router.push(DownloadedAlbumDetailRoute(albumGroupId: albumGroupId));
}
