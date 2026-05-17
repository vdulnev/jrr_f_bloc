import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/folder_tracks_cubit.dart';
import '../bloc/library_async_state.dart';
import '../data/models/track.dart';
import '../data/models/tracks.dart';
import '../data/repositories/library_repository.dart';
import 'track_list_scaffold.dart';

class FolderTracksScreen extends StatefulWidget {
  final String folderPath;

  const FolderTracksScreen({required this.folderPath, super.key});

  @override
  State<FolderTracksScreen> createState() => _FolderTracksScreenState();
}

class _FolderTracksScreenState extends State<FolderTracksScreen> {
  late String _currentPath;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _currentPath = widget.folderPath;
  }

  bool get _canGoUp {
    final parent = Track.parentPath(_currentPath);
    return parent.isNotEmpty && parent != _currentPath;
  }

  bool get _canGoBack => _history.isNotEmpty;

  void _goUp() {
    final parent = Track.parentPath(_currentPath);
    if (parent.isNotEmpty && parent != _currentPath) {
      setState(() {
        _history.add(_currentPath);
        _currentPath = parent;
      });
    }
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() => _currentPath = _history.removeLast());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(_currentPath),
      create: (_) => FolderTracksCubit(
        folderPath: _currentPath,
        repository: getIt<LibraryRepository>(),
      ),
      child: BlocBuilder<FolderTracksCubit, LibAsync<Tracks>>(
        builder: (context, state) => TrackListScaffold(
          subtitle: 'Folder',
          onBack: () => Navigator.of(context).maybePop(),
          title: Text(_currentPath, style: AppTextStyles.subScreenTitle),
          headerContent: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 20),
                tooltip: 'Back to child folder',
                visualDensity: VisualDensity.compact,
                onPressed: _canGoBack ? _goBack : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 20),
                tooltip: 'Go to parent folder',
                visualDensity: VisualDensity.compact,
                onPressed: _canGoUp ? _goUp : null,
              ),
            ],
          ),
          tracksState: state,
          onRetry: () => context.read<FolderTracksCubit>().load(),
          actionSheetTitle: _currentPath,
          addedSnackbarLabel: _currentPath,
        ),
      ),
    );
  }
}
