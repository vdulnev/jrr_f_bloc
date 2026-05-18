import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/connection/bloc/artwork_cubit.dart';
import '../../features/connection/bloc/artwork_state.dart';

class ArtworkWidget extends StatelessWidget {
  final int? fileKey;
  final double size;

  const ArtworkWidget({super.key, required this.fileKey, this.size = 280});

  @override
  Widget build(BuildContext context) {
    final key = fileKey;
    if (key == null || key < 0) return _placeholder(context);

    return BlocBuilder<ArtworkCubit, ArtworkState>(
      builder: (context, state) {
        final url = state.urlFor(key);
        if (url == null) return _placeholder(context);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(context),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _placeholder(context);
            },
          ),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.music_note,
        size: size * 0.4,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
