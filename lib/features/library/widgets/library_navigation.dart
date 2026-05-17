import 'package:flutter/material.dart';

import '../data/models/album.dart';
import 'album_detail_screen.dart';
import 'artist_albums_screen.dart';
import 'folder_tracks_screen.dart';

/// Phase 9 will route this through auto_route. For now plain
/// [Navigator.push] is sufficient — every library screen routes through
/// these three helpers.
void pushArtistAlbums(BuildContext context, String artist) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ArtistAlbumsScreen(artist: artist)),
  );
}

void pushAlbumDetail(BuildContext context, Album album) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => AlbumDetailScreen(album: album)),
  );
}

void pushFolderTracks(BuildContext context, String folderPath) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => FolderTracksScreen(folderPath: folderPath)),
  );
}
