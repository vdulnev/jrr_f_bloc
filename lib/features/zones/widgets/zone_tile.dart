import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/models/zone.dart';

/// A single row in the zone list. The play/pause indicator and the
/// audio-quality popup depend on PlayerCubit / LocalAudioQualityCubit and
/// are wired in Phase 5.
class ZoneTile extends StatelessWidget {
  final Zone zone;
  final bool isActive;
  final VoidCallback onTap;

  const ZoneTile({
    super.key,
    required this.zone,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentDim : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.bg3,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                _iconFor(zone),
                size: 20,
                color: _iconColor(isActive),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: AppTextStyles.itemTitle.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_subtitle(zone) != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _subtitle(zone)!,
                        style: AppTextStyles.monoLabel,
                      ),
                    ),
                ],
              ),
            ),
            if (isActive)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(Zone z) {
    if (z.isAndroidAuto) return Icons.directions_car_rounded;
    if (z.isLocal) return Icons.smartphone_rounded;
    if (z.isOffline) return Icons.cloud_off_rounded;
    if (z.isDLNA) return Icons.cast_rounded;
    return Icons.speaker_rounded;
  }

  static Color _iconColor(bool isActive) =>
      isActive ? AppColors.accent : AppColors.text3;

  static String? _subtitle(Zone z) {
    if (z.isAndroidAuto) return 'ANDROID AUTO';
    if (z.isLocal) return 'LOCAL';
    if (z.isOffline) return 'OFFLINE';
    if (z.isDLNA) return 'DLNA';
    return null;
  }
}
