import 'package:flutter/material.dart';

/// Face enrollment screen — captures 3 photos from different angles
/// and creates a stored embedding vector for future verification.
class FaceEnrollScreen extends StatelessWidget {
  const FaceEnrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Face Enrollment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural,
                size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Set Up Face ID',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'We\'ll take 3 photos of your face from different angles. '
              'Your face data stays on this device — only a mathematical '
              'vector is stored.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // TODO: Implement camera capture with 3-angle guide
            FilledButton.icon(
              onPressed: () {
                // TODO: Start camera and capture 3 angles
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Enrollment'),
            ),
          ],
        ),
      ),
    );
  }
}
