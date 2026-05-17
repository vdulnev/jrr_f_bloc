// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AlbumDetailScreen]
class AlbumDetailRoute extends PageRouteInfo<AlbumDetailRouteArgs> {
  AlbumDetailRoute({
    required Album album,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AlbumDetailRoute.name,
         args: AlbumDetailRouteArgs(album: album, key: key),
         initialChildren: children,
       );

  static const String name = 'AlbumDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AlbumDetailRouteArgs>();
      return AlbumDetailScreen(album: args.album, key: args.key);
    },
  );
}

class AlbumDetailRouteArgs {
  const AlbumDetailRouteArgs({required this.album, this.key});

  final Album album;

  final Key? key;

  @override
  String toString() {
    return 'AlbumDetailRouteArgs{album: $album, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AlbumDetailRouteArgs) return false;
    return album == other.album && key == other.key;
  }

  @override
  int get hashCode => album.hashCode ^ key.hashCode;
}

/// generated route for
/// [ArtistAlbumsScreen]
class ArtistAlbumsRoute extends PageRouteInfo<ArtistAlbumsRouteArgs> {
  ArtistAlbumsRoute({
    required String artist,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         ArtistAlbumsRoute.name,
         args: ArtistAlbumsRouteArgs(artist: artist, key: key),
         initialChildren: children,
       );

  static const String name = 'ArtistAlbumsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArtistAlbumsRouteArgs>();
      return ArtistAlbumsScreen(artist: args.artist, key: args.key);
    },
  );
}

class ArtistAlbumsRouteArgs {
  const ArtistAlbumsRouteArgs({required this.artist, this.key});

  final String artist;

  final Key? key;

  @override
  String toString() {
    return 'ArtistAlbumsRouteArgs{artist: $artist, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArtistAlbumsRouteArgs) return false;
    return artist == other.artist && key == other.key;
  }

  @override
  int get hashCode => artist.hashCode ^ key.hashCode;
}

/// generated route for
/// [ConnectingScreen]
class ConnectingRoute extends PageRouteInfo<ConnectingRouteArgs> {
  ConnectingRoute({Key? key, String? address, List<PageRouteInfo>? children})
    : super(
        ConnectingRoute.name,
        args: ConnectingRouteArgs(key: key, address: address),
        initialChildren: children,
      );

  static const String name = 'ConnectingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ConnectingRouteArgs>(
        orElse: () => const ConnectingRouteArgs(),
      );
      return ConnectingScreen(key: args.key, address: args.address);
    },
  );
}

class ConnectingRouteArgs {
  const ConnectingRouteArgs({this.key, this.address});

  final Key? key;

  final String? address;

  @override
  String toString() {
    return 'ConnectingRouteArgs{key: $key, address: $address}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConnectingRouteArgs) return false;
    return key == other.key && address == other.address;
  }

  @override
  int get hashCode => key.hashCode ^ address.hashCode;
}

/// generated route for
/// [DownloadedAlbumDetailScreen]
class DownloadedAlbumDetailRoute
    extends PageRouteInfo<DownloadedAlbumDetailRouteArgs> {
  DownloadedAlbumDetailRoute({
    required String albumGroupId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         DownloadedAlbumDetailRoute.name,
         args: DownloadedAlbumDetailRouteArgs(
           albumGroupId: albumGroupId,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'DownloadedAlbumDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DownloadedAlbumDetailRouteArgs>();
      return DownloadedAlbumDetailScreen(
        albumGroupId: args.albumGroupId,
        key: args.key,
      );
    },
  );
}

class DownloadedAlbumDetailRouteArgs {
  const DownloadedAlbumDetailRouteArgs({required this.albumGroupId, this.key});

  final String albumGroupId;

  final Key? key;

  @override
  String toString() {
    return 'DownloadedAlbumDetailRouteArgs{albumGroupId: $albumGroupId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DownloadedAlbumDetailRouteArgs) return false;
    return albumGroupId == other.albumGroupId && key == other.key;
  }

  @override
  int get hashCode => albumGroupId.hashCode ^ key.hashCode;
}

/// generated route for
/// [DownloadedAlbumsScreen]
class DownloadedAlbumsRoute extends PageRouteInfo<DownloadedAlbumsRouteArgs> {
  DownloadedAlbumsRoute({
    required String artist,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         DownloadedAlbumsRoute.name,
         args: DownloadedAlbumsRouteArgs(artist: artist, key: key),
         initialChildren: children,
       );

  static const String name = 'DownloadedAlbumsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DownloadedAlbumsRouteArgs>();
      return DownloadedAlbumsScreen(artist: args.artist, key: args.key);
    },
  );
}

class DownloadedAlbumsRouteArgs {
  const DownloadedAlbumsRouteArgs({required this.artist, this.key});

  final String artist;

  final Key? key;

  @override
  String toString() {
    return 'DownloadedAlbumsRouteArgs{artist: $artist, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DownloadedAlbumsRouteArgs) return false;
    return artist == other.artist && key == other.key;
  }

  @override
  int get hashCode => artist.hashCode ^ key.hashCode;
}

/// generated route for
/// [FolderTracksScreen]
class FolderTracksRoute extends PageRouteInfo<FolderTracksRouteArgs> {
  FolderTracksRoute({
    required String folderPath,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         FolderTracksRoute.name,
         args: FolderTracksRouteArgs(folderPath: folderPath, key: key),
         initialChildren: children,
       );

  static const String name = 'FolderTracksRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FolderTracksRouteArgs>();
      return FolderTracksScreen(folderPath: args.folderPath, key: args.key);
    },
  );
}

class FolderTracksRouteArgs {
  const FolderTracksRouteArgs({required this.folderPath, this.key});

  final String folderPath;

  final Key? key;

  @override
  String toString() {
    return 'FolderTracksRouteArgs{folderPath: $folderPath, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FolderTracksRouteArgs) return false;
    return folderPath == other.folderPath && key == other.key;
  }

  @override
  int get hashCode => folderPath.hashCode ^ key.hashCode;
}

/// generated route for
/// [RootRoutePage]
class RootRoute extends PageRouteInfo<void> {
  const RootRoute({List<PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RootRoutePage();
    },
  );
}

/// generated route for
/// [ServerSetupScreen]
class ServerSetupRoute extends PageRouteInfo<void> {
  const ServerSetupRoute({List<PageRouteInfo>? children})
    : super(ServerSetupRoute.name, initialChildren: children);

  static const String name = 'ServerSetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ServerSetupScreen();
    },
  );
}
