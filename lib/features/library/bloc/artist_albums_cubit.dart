import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

import '../data/models/album.dart';
import '../data/models/album_group.dart';
import '../data/models/albums.dart';
import '../data/repositories/library_repository.dart';
import 'library_async_state.dart';

/// Loads albums for a single artist and folds multi-disc albums into
/// [AlbumGroup]s per spec §4.17.
class ArtistAlbumsCubit extends Cubit<LibAsync<List<AlbumGroup>>> {
  final LibraryRepository _repo;
  final Talker _talker;
  final String artist;

  ArtistAlbumsCubit({
    required this.artist,
    required LibraryRepository repository,
    required Talker talker,
  }) : _repo = repository,
       _talker = talker,
       super(const LibAsync.loading()) {
    load();
  }

  Future<void> load() async {
    emit(const LibAsync.loading());
    final result = await _repo.getAlbumsByArtist(artist);
    result.fold(
      (e) => emit(LibAsync.error(error: e)),
      (albums) => emit(LibAsync.data(value: _buildGroups(artist, albums))),
    );
  }

  List<AlbumGroup> _buildGroups(String artist, Albums albums) {
    const tag = '[ArtistAlbumsCubit]';
    _talker.debug('$tag [$artist] Received ${albums.length} album row(s)');

    final sortedAlbums = [...albums.albums]
      ..sort((a, b) => a.name.compareTo(b.name));

    final discBuckets = <String, List<Album>>{};
    final singles = <Album>[];

    for (final album in sortedAlbums) {
      final isMultiDiscRow =
          album.totalDiscs > 1 &&
          album.discNumber > 0 &&
          album.parentFolderPath.isNotEmpty;
      if (isMultiDiscRow) {
        final key =
            '${album.name.toLowerCase()}|${album.parentFolderPath.toLowerCase()}';
        discBuckets.putIfAbsent(key, () => []).add(album);
      } else {
        singles.add(album);
      }
    }

    final groups = <AlbumGroup>[];

    for (final entry in discBuckets.entries) {
      final discs = entry.value
        ..sort((a, b) => a.discNumber.compareTo(b.discNumber));

      if (discs.length > 1) {
        final first = discs.first;
        final latestDate =
            discs.map((d) => d.date).where((d) => d.isNotEmpty).toList()
              ..sort();
        final parent = first.copyWith(
          folderPath: first.parentFolderPath,
          discNumber: 0,
          date: latestDate.isNotEmpty ? latestDate.last : first.date,
        );
        groups.add(AlbumGroup(album: parent, discs: discs));
      } else {
        groups.add(AlbumGroup(album: discs.first));
      }
    }

    for (final album in singles) {
      groups.add(AlbumGroup(album: album));
    }

    groups.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.album.name.compareTo(b.album.name);
    });

    _talker.info(
      '$tag [$artist] Built ${groups.length} group(s) from '
      '${albums.length} row(s)',
    );

    return groups;
  }
}
