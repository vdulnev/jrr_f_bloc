import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../bloc/active_zone_cubit.dart';
import '../bloc/zones_cubit.dart';
import '../bloc/zones_state.dart';
import 'zone_tile.dart';

class ZoneListScreen extends StatelessWidget {
  const ZoneListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OUTPUT', style: AppTextStyles.sectionLabel),
                        SizedBox(height: 6),
                        Text('Zones', style: AppTextStyles.screenTitle),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.read<ZonesCubit>().refresh(),
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.text2,
                    tooltip: 'Refresh zones',
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ZonesCubit, ZonesState>(
                builder: (context, state) => switch (state) {
                  ZonesLoading() => const LoadingView(),
                  ZonesError(:final error) => ErrorView(
                    error: error,
                    onRetry: () => context.read<ZonesCubit>().refresh(),
                  ),
                  ZonesLoaded(:final zones) =>
                    BlocBuilder<ActiveZoneCubit, dynamic>(
                      builder: (context, active) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: zones.length,
                          itemBuilder: (_, i) {
                            final zone = zones[i];
                            return ZoneTile(
                              zone: zone,
                              isActive: active?.id == zone.id,
                              onTap: () => context
                                  .read<ActiveZoneCubit>()
                                  .setZone(zone),
                            );
                          },
                        );
                      },
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
