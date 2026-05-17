import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../core/router/app_router.dart';
import '../data/models/album.dart';

void pushArtistAlbums(BuildContext context, String artist) {
  context.router.push(ArtistAlbumsRoute(artist: artist));
}

void pushAlbumDetail(BuildContext context, Album album) {
  context.router.push(AlbumDetailRoute(album: album));
}

void pushFolderTracks(BuildContext context, String folderPath) {
  context.router.push(FolderTracksRoute(folderPath: folderPath));
}
