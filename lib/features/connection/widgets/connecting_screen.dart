import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ConnectingScreen extends StatelessWidget {
  final String? address;

  const ConnectingScreen({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text('Connecting to', style: AppTextStyles.itemSubtitle),
            const SizedBox(height: 8),
            if (address != null)
              Text(
                address!,
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 14,
                  color: AppColors.text,
                ),
              )
            else
              const Text('server…', style: AppTextStyles.monoLabel),
          ],
        ),
      ),
    );
  }
}
