import 'package:flutter/material.dart';

import '../../offline/widgets/downloaded_artists_screen.dart';

/// Library tab for the local download cache. Re-uses the offline-feature
/// downloaded-artists screen but lives in the library tab strip so the
/// user finds their offline music alongside live browsing.
class DownloadsTab extends StatelessWidget {
  const DownloadsTab({super.key});

  @override
  Widget build(BuildContext context) => const DownloadedArtistsScreen();
}
