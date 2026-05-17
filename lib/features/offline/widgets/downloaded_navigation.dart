import 'package:flutter/material.dart';

import 'downloaded_album_detail_screen.dart';
import 'downloaded_albums_screen.dart';

void pushDownloadedAlbums(BuildContext context, String artist) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DownloadedAlbumsScreen(artist: artist),
    ),
  );
}

void pushDownloadedAlbumDetail(BuildContext context, String albumGroupId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          DownloadedAlbumDetailScreen(albumGroupId: albumGroupId),
    ),
  );
}
