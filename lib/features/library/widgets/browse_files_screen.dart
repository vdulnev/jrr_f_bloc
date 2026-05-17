import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/browse_files_cubit.dart';
import '../bloc/library_async_state.dart';
import '../data/repositories/library_repository.dart';
import 'track_list_scaffold.dart';

class BrowseFilesScreen extends StatelessWidget {
  final String id;
  final String name;

  const BrowseFilesScreen({required this.id, required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BrowseFilesCubit(id: id, repository: getIt<LibraryRepository>()),
      child: BlocBuilder<BrowseFilesCubit, LibAsync<dynamic>>(
        builder: (context, _) {
          final state = context.read<BrowseFilesCubit>().state;
          return TrackListScaffold(
            title: Text(name, style: AppTextStyles.subScreenTitle),
            tracksState: state,
            onRetry: () => context.read<BrowseFilesCubit>().load(),
            actionSheetTitle: name,
            addedSnackbarLabel: name,
          );
        },
      ),
    );
  }
}
