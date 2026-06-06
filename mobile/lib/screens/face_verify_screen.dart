import 'package:flutter/material.dart';

/// Face verification screen — used for device migration.
/// When a student tries to log in from a new phone, they must
/// verify their face to re-bind the device lock.
class FaceVerifyScreen extends StatelessWidget {
  const FaceVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Device Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phonelink_lock,
                size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              'New Device Detected',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your account is linked to a different device. '
              'Verify your identity with face recognition to '
              'transfer your account to this phone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Run liveness + face verification
                // On success: DeviceLockService.migrateDevice()
              },
              icon: const Icon(Icons.face),
              label: const Text('Verify My Face'),
            ),
          ],
        ),
      ),
    );
  }
}
