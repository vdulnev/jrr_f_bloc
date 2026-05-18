import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../router/navigation_cubit.dart';
import '../theme/app_theme.dart';

/// Side-rail nav used by the wide-screen shell. Mirrors the bottom
/// NavigationBar but with a logo + label per row.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg1,
      child: Container(
        width: 280,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.line)),
        ),
        child: BlocBuilder<NavigationCubit, AppTab>(
          builder: (context, active) => Column(
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'JRR',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _NavItem(
                icon: Icons.album_outlined,
                label: 'Now Playing',
                isActive: active == AppTab.nowPlaying,
                onTap: () =>
                    context.read<NavigationCubit>().select(AppTab.nowPlaying),
              ),
              _NavItem(
                icon: Icons.queue_music_outlined,
                label: 'Queue',
                isActive: active == AppTab.queue,
                onTap: () =>
                    context.read<NavigationCubit>().select(AppTab.queue),
              ),
              _NavItem(
                icon: Icons.library_music_outlined,
                label: 'Library',
                isActive: active == AppTab.library,
                onTap: () =>
                    context.read<NavigationCubit>().select(AppTab.library),
              ),
              _NavItem(
                icon: Icons.speaker_group_outlined,
                label: 'Zones',
                isActive: active == AppTab.zones,
                onTap: () =>
                    context.read<NavigationCubit>().select(AppTab.zones),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isActive: active == AppTab.settings,
                onTap: () =>
                    context.read<NavigationCubit>().select(AppTab.settings),
              ),
              const Spacer(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentDim : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.accent : AppColors.text3,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.accent : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
