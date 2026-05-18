import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../active_zone_service.dart';
import '../bloc/zone_list_cubit.dart';
import '../bloc/zone_list_state.dart';
import '../bloc/zones_cubit.dart';
import 'zone_tile.dart';

class ZoneListScreen extends StatelessWidget {
  const ZoneListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZoneListCubit>(
      create: (ctx) => ZoneListCubit(
        zones: ctx.read<ZonesCubit>(),
        activeZone: getIt<ActiveZoneService>(),
      ),
      child: const _ZoneListView(),
    );
  }
}

class _ZoneListView extends StatelessWidget {
  const _ZoneListView();

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
                    onPressed: () => context.read<ZoneListCubit>().refresh(),
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.text2,
                    tooltip: 'Refresh zones',
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ZoneListCubit, ZoneListState>(
                builder: (context, state) => switch (state) {
                  ZoneListLoading() => const LoadingView(),
                  ZoneListError(:final error) => ErrorView(
                    error: error,
                    onRetry: () => context.read<ZoneListCubit>().refresh(),
                  ),
                  ZoneListLoaded(:final zones, :final activeZone) =>
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: zones.length,
                      itemBuilder: (_, i) {
                        final zone = zones[i];
                        return ZoneTile(
                          zone: zone,
                          isActive: activeZone?.id == zone.id,
                          onTap: () =>
                              context.read<ZoneListCubit>().setZone(zone),
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
