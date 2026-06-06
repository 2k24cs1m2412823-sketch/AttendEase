import 'package:flutter/material.dart';

/// Damage report screen with photo upload.
class DamageReportScreen extends StatelessWidget {
  final String seatId;
  final String sessionId;

  const DamageReportScreen({
    super.key,
    required this.seatId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Report Damage — Seat $seatId')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 80, color: theme.colorScheme.tertiary),
            const SizedBox(height: 24),
            Text(
              'Take Photo of Damage',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Document the existing damage before sitting down. '
              'This protects you from liability for pre-existing issues.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Open camera, capture photo, upload to Firebase Storage
              },
              icon: const Icon(Icons.photo_camera),
              label: const Text('Capture & Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
